require_relative 'log'
require_relative 'objects/graph'
require_relative 'objects/edge'

require_relative 'evaluator'

class RuleApplication

    def initialize(rule, graph, tracer=nil)
        @log = Log.new("RuleApplication:#{rule.name}")
        @log.set_level(Log::ALL) if $verbose
        @rule = rule
        @graph = graph
        @tracer = tracer
    end

    def attempt
        @tracer&.push("[Rule::#{@rule.name}] Attempted.")
        @tracer&.save_graph(@graph)

        mappings = find_mappings

        if mappings.empty?
            @log.trace("No possible applications.")
            @tracer&.pop("[Rule::#{@rule.name}] Failed. No matches.")
            return Graph::INVALID
        else
            @log.trace("Final possible mappings:")
            @log.trace(mappings.map { |pm| 
                pm.map { |k, v| 
                    "#{k.id} => #{v.id}" 
                }.join(", ") 
            }.join("\n"))
            @tracer&.append("[Rule::#{@rule.name}] Matched.")
            @tracer&.push("[Rule::#{@rule.name}] Possible Mappings: ")
            mappings.each do |m|
                @tracer&.append m.map { |k, v| 
                    "#{k.id} => #{v.id}" 
                }.join(", ")
            end
            @tracer&.pop
        end

        # All mappings at this point should be applied successfuly.

        mapping = mappings.sample

        @tracer&.push("[Rule::#{@rule.name}] Chosen Mapping: ")
        @tracer&.append mapping.map { |k, v| 
            "#{k.id} => #{v.id}" 
        }.join(", ")
        @tracer&.pop

        new_graph = apply(mapping)

        @tracer&.pop("[Rule::#{@rule.name}] Completed.")
        @tracer&.save_graph(new_graph)
        return new_graph
    end

    def added_rule_nodes 
        return @rule.result_graph.nodes.select { |node| 
            !@rule.match_graph.nodes.any? { |n| node.id == n.id }
        }
    end

    def removed_rule_nodes
        return @rule.match_graph.nodes.select { |node| 
            !@rule.result_graph.nodes.any? { |n| node.id == n.id }
        }
    end

    def find_mappings
        @log.trace("Attempting to apply a rule.")

        @log.trace("Current Host Graph:")
        @log.trace(@graph.to_s)
        @log.trace("Rule Match Graph:")
        @log.trace(@rule.match_graph.to_s)
        @log.trace("Rule Result Graph:")
        @log.trace(@rule.result_graph.to_s)

        #------------------------#
        # Find possible mappings #
        #------------------------#

        possible_matches = [{}]

        @rule.match_graph.nodes.each do |rule_node|
            node_matches = @graph.nodes.select do |graph_node| 
                nodes_match?(rule_node, graph_node, @rule.match_graph.edges, @graph.edges) 
            end
            possible_matches = possible_matches.map { |existing_match|
                node_matches.map { |matched_node| 
                    new_match = existing_match.clone
                    new_match[rule_node] = matched_node
                    new_match
                }.flatten
            }.flatten
        end

        return [] if possible_matches.empty?

        @log.trace("Initial possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        # Any removed nodes must not be incident to any edges not in the rule.
        # (the host graph's node must not have a higher incident value than the initial graph's node).
        # Otherwise it will not satisfy the DANGLING CONDITION.

        adjacent_graph_edge_count = {}
        @graph.nodes.each do |n|
            adjacent_graph_edge_count[n] = @graph.edges.count { |e| e.source_id == n.id || e.target_id == n.id }
        end
        adjacent_rule_edge_count = {}
        @rule.match_graph.nodes.each do |n|
            adjacent_rule_edge_count[n] = @rule.match_graph.edges.count { |e| e.source_id == n.id || e.target_id == n.id }
        end

        removed_rule_nodes = @rule.match_graph.nodes.select { |node| 
            !@rule.result_graph.nodes.any? { |n| node.id == n.id }
        }
        removed_rule_nodes.each do |removed_rule_node|
            possible_matches = possible_matches.reject do |mapping| 
                mapping.has_key?(removed_rule_node) &&
                adjacent_graph_edge_count[mapping[removed_rule_node]] > adjacent_rule_edge_count[removed_rule_node]
            end
        end

        @log.trace("Removed mappings that create dangling edges.")
        @log.trace("Remaining possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        # Any node matches must have edges in the host graph, if they have edges in the rule graph.

        # TODO: Does this work? It looks like rule r1 [1,2|1->2, 1->2] will match the graph [1,2|1->2]
        #       and that both the rule edges will be mapped to the same graph edge. This seems wrong.
        #       Maybe do a count again. Unless multiple edges can be mapped to the same edge?

        possible_matches = possible_matches.select do |mapping|
            id_mapping = {}
            mapping.each { |k, v| id_mapping[k.id] = v.id }
            @rule.match_graph.edges.all? do |rule_edge|
                @graph.edges.any? do |graph_edge|
                    graph_edge.source_id == id_mapping[rule_edge.source_id] &&
                    graph_edge.target_id == id_mapping[rule_edge.target_id] &&
                    edges_match?(rule_edge, graph_edge)
                end
            end
        end

        @log.trace("Removed mappings without required edges.")
        @log.trace("Remaining possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        # I may or may not later on decide that you can't have more than one variable used in a rule, 
        # and if you want to check equality of two nodes' label values, you can have that in the rule's condition.
        # HOWEVER, at the moment you can, and so the same variable cannot point to different values, which lowers
        # the possible matches it can have.

        @variable_types = {}
        @rule.parameters.each do |name, param|
            var_rule_node = @rule.match_graph.nodes.find { |node| node.label.value.is_a?(VariableLabelExpression) && node.label.value.name == name }
            var_rule_edge = @rule.match_graph.edges.find { |edge| edge.label.value.is_a?(VariableLabelExpression) && edge.label.value.name == name }
            if var_rule_node.nil? && var_rule_edge.nil?
                @log.warn("Variable '#{name}' is never used.")
            else
                @variable_types[name] = param[:type_name]
            end
        end

        possible_matches = possible_matches.select do |mapping|
            id_mapping = {}
            mapping.each { |k, v| id_mapping[k.id] = v.id }
            variable_values = {}
            @variable_types.each do |name, type|
                var_node = @rule.match_graph.nodes.find { |node| node.label.value.is_a?(VariableLabelExpression) && node.label.value.name == name }
                if !var_node.nil?
                    variable_values[name] = mapping[var_node].label.value.value
                else
                    var_edge = @rule.match_graph.edges.find { |edge| edge.label.value.is_a?(VariableLabelExpression) && edge.label.value.name == name }
                    if !var_edge.nil?
                        rule_var_edge_count = @rule.match_graph.edges.count { |edge| edge.label.value.is_a?(VariableLabelExpression) && edge.label.value.name == name }
                        graph_var_values = @graph.edges.select   { |edge| edge.label.value.is_a?(LiteralLabelExpression) && edge.label.type == @variable_types[name] }
                                                       .group_by { |edge| edge.label.value.value }
                                                       .select   { |value, edges| edges.size >= rule_var_edge_count }
                        @log.trace("Variable #{name} only exists in edge labels in the matching graph.")
                        if graph_var_values.size > 1
                            @log.trace("There are #{graph_var_values.size} possible values for #{name} variable.")
                        end
                        variable_values[name] = graph_var_values.keys.sample
                    end
                end
            end
            @rule.match_graph.nodes.select { |node| node.label.value.is_a?(VariableLabelExpression) }
                                   .all?   { |node| variable_values[node.label.value.name] == mapping[node].label.value.value } &&
            @rule.match_graph.edges.select   { |edge| edge.label.value.is_a?(VariableLabelExpression) }
                                   .group_by { |edge| edge.label.value.name }
                                   .all?     { |name, edges| edges.all? { |edge|
                    source_id = id_mapping[edge.source_id]
                    target_id = id_mapping[edge.target_id]
                    @graph.edges.count { |e| e.source_id == source_id && e.target_id == target_id  } >= edges.size
                }
            }
        end

        @log.trace("Removed mappings with conflicting variable usage.")
        @log.trace("Remaining possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        # If not all the rule's match graph's nodes have a match in the graph, then the rule is not matched.

        possible_matches.reject! do |mapping|
            mapping.size != @rule.match_graph.nodes.size
        end

        @log.trace("Removed mappings that don't include all rule nodes.")
        @log.trace("Remaining possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        # Check rule's condition (with possible mappings in order to further whittle down the viable applications).

        possible_matches = possible_matches.select do |mapping|
            condition_holds?(mapping)
        end

        @log.trace("Removed mappings that don't satisfy the rule's condition.")
        @log.trace("Remaining possible mappings:")
        @log.trace(possible_matches.map { |pm| 
            pm.map { |k, v| 
                "#{k.id} => #{v.id}" 
            }.join(", ") 
        }.join("\n"))

        return possible_matches
    end

    def apply(application)
        @log.trace("#{added_rule_nodes.size} nodes to add.")
        @log.trace("#{removed_rule_nodes.size} nodes to remove.")

        @log.trace("Chosen application:")
        @log.trace(application.map { |k, v| 
            "#{k.id} => #{v.id}" 
        }.join(", "))

        variable_values = {}
        @variable_types.each do |name, type|
            var_node = @rule.match_graph.nodes.find { |node| node.label.value.is_a?(VariableLabelExpression) && node.label.value.name == name }
            if !var_node.nil?
                variable_values[name] = application[var_node].label.value.value
                @log.trace("#{name} (#{type}) = #{application[var_node].label.value.value}")
            else
                var_edge = @rule.match_graph.edges.find { |edge| edge.label.value.is_a?(VariableLabelExpression) && edge.label.value.name == name }
                if !var_edge.nil?
                    rule_var_edge_count = @rule.match_graph.edges.count { |edge| edge.label.value.is_a?(VariableLabelExpression) && edge.label.value.name == name }
                    graph_var_values = @graph.edges.select   { |edge| edge.label.value.is_a?(LiteralLabelExpression) && edge.label.type == @variable_types[name] }
                                                   .group_by { |edge| edge.label.value.value }
                                                   .select   { |value, edges| edges.size >= rule_var_edge_count }
                    @log.trace("Variable #{name} only exists in edge labels in the matching graph.")
                    if graph_var_values.size > 1
                        @log.trace("There are #{graph_var_values.size} possible values for #{name} variable.")
                    end
                    variable_values[name] = graph_var_values.keys.sample
                    @log.trace("#{name} (#{type}) = #{variable_values[name]}")
                else
                    @log.warn("Variable #{name} is never used.")
                end
            end
        end

        new_graph = @graph.clone
        added_node_mappings = {}

        added_rule_nodes.each do |rule_node|
            evaluator = LabelEvaluator.new(rule_node.label, nil, variable_values)
            node_label_value = evaluator.evaluate

            if node_label_value.nil?
                node_label_value = MatcherLabelExpression.new(:void)
                node_label_type = nil
            else
                node_label_value = LiteralLabelExpression.new(node_label_value)
                node_label_type = node_label_value.type
            end

            new_label = Label.new(node_label_value, node_label_type, rule_node.label&.markset.to_a)

            added_node = new_graph.add_node(new_label)
            added_node_mappings[rule_node.id] = added_node.id
        end
        @log.trace("Added new nodes.")

        removed_rule_nodes.each do |rule_node|
            new_graph.remove_node(application[rule_node].id)
        end
        @log.trace("Removed old nodes.")

        id_mapping = {}
        application.each { |k, v| id_mapping[k.id] = v.id }
        added_node_mappings.each { |k, v| id_mapping[k] = v }

        @rule.match_graph.edges.each do |rule_edge|
            source_id = id_mapping[rule_edge.source_id]
            target_id = id_mapping[rule_edge.target_id]
            remove_edge = new_graph.edges.find do |graph_edge|
                graph_edge.source_id == source_id &&
                graph_edge.target_id == target_id &&
                edges_match?(rule_edge, graph_edge)
            end
            new_graph.edges.delete(remove_edge)
        end
        @log.trace("Removed edges.")

        @rule.result_graph.edges.each do |rule_edge|
            source_id = id_mapping[rule_edge.source_id]
            target_id = id_mapping[rule_edge.target_id]

            evaluator = LabelEvaluator.new(rule_edge.label, nil, variable_values)
            label_value = evaluator.evaluate
            if label_value.nil?
                label_value = MatcherLabelExpression.new(:void)
            else
                label_value = LiteralLabelExpression.new(label_value)
                label_type = label_value.type
            end
            new_label = Label.new(label_value, label_type, rule_edge.label.markset)

            graph_edge = Edge.new(source_id, target_id, new_label)
            new_graph.edges.push(graph_edge)
        end

        @log.trace("Added edges.")

        persiting_rule_nodes = @rule.match_graph.nodes.select { |node| 
            @rule.result_graph.nodes.any? { |n| node.id == n.id }
        }

        persiting_rule_nodes.each do |rule_node|
            rule_node_before = rule_node
            rule_node_after  = @rule.result_graph.nodes.find { |n| n.id == rule_node.id }
            current_graph_node = @graph.nodes.find { |n| n.id == id_mapping[rule_node_before.id] }
            new_node = apply_node_change(rule_node_before, rule_node_after, current_graph_node, variable_values)
            new_graph.update_node(current_graph_node.id, new_node.label)
        end

        @log.trace("Updated nodes.")

        @log.trace("Resultant graph:")
        @log.trace(new_graph.to_s)

        if !@rule.addendum.nil?
            executor = AddendumExecutor.new(@rule.addendum, @graph, id_mapping, variable_values)
            executor.execute
        end

        return new_graph
    end

    def nodes_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        return false if !label_value_match?(rule_node.label, graph_node.label)
        return false if !markset_match?(rule_node.label, graph_node.label)
        return false if !adj_edges_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        # ...
        return true
    end

    def edges_match?(rule_edge, graph_edge)
        return false if !label_value_match?(rule_edge.label, graph_edge.label)
        return false if !markset_match?(rule_edge.label, graph_edge.label)
        # ...
        return true
    end

    # Rule node labels have a label_value_expression as their value, and an array of strings as their markset
    # Graph node labels have, as their value, either nil (for `void`) or a literal value. 
    # They may also have nil for their whole label if it is not given (for `empty`).
    def label_value_match?(rule_label, graph_label)

        # TODO: the following code is wrong somehow...
        if @rule.name == "start" || @rule.name == "order"
            @log.set_level(Log::ALL)
            @log.set_output(File.open("trace/debug.log", 'a'))
        end

        @log.trace("Checking label equality")
        if rule_label.value.nil?
            @log.trace("Rule label is nil (matches anything).")
            return true 
        end

        if rule_label.value.is_a?(MatcherLabelExpression) && rule_label.value.keyword == :any
            @log.trace("Rule label is any (matches anything).")
            return true
        end
        if rule_label.value.is_a?(MatcherLabelExpression) && rule_label.value.keyword == :empty
            @log.trace("Checking for empty: " + (graph_label.nil? ? "Found." : "Not found."))
            return graph_label.nil?
        end
        if rule_label.value.is_a?(MatcherLabelExpression) && rule_label.value.keyword == :void
            @log.trace("Checking for void: " + (graph_label.value.nil? ? "Found." : "Not found."))
            return graph_label.value.nil?
        end
        if rule_label.value.variable?
            @log.trace("Checking for variable")
            if rule_label.type == :any
                @log.trace("Checking for any value: " + (!graph_label.value.nil? ? "Found." : "Not found." ))
                return graph_label.value != nil
            else
                @log.trace("Checking for #{rule_label.type} value: " + (rule_label.type == graph_label.type ? "Found." : "Not found." ))
                return rule_label.type == graph_label.type
            end
        end
        if rule_label.value.is_a?(LiteralLabelExpression)
            @log.trace("Checking values")
            @log.trace(rule_label.value.inspect)
            @log.trace(graph_label.value.inspect)
            return rule_label.value.value == graph_label.value.value
        end
        @log.fatal("Unaccounted-for label value pairing: ")
        @log.fatal(rule_label)
        @log.fatal(graph_label)
        raise "Unaccounted-for label value pairing."
    end

    def markset_match?(rule_label, graph_label)
        if rule_label.markset.nil?
            return graph_label.markset.empty?
        end
        
        return true if rule_label.markset.empty?

        if rule_label.markset.select { |m| m[0] == "#" }
                             .any? { |m| !graph_label.markset.include?(m) }
            return false
        end
        if rule_label.markset.select { |m| m[0] == "¬" }
                             .any? { |m| graph_label.markset.include?('#'+m[1..-1]) }
            return false
        end
        return true
    end

    def adj_edges_match?(rule_node, graph_node, rule_edges, graph_edges)
        in_edges  = rule_edges.count { |e| e.target_id == rule_node.id }
        out_edges = rule_edges.count { |e| e.source_id == rule_node.id }
        if in_edges > 0 && graph_edges.count { |e| e.target_id == graph_node.id } < in_edges
            return false
        end
        if out_edges > 0 && graph_edges.count { |e| e.source_id == graph_node.id } < out_edges
            return false
        end
        return true
    end

    def condition_holds?(mapping)
        return true if @rule.condition.nil?
        @log.trace("Checking rule's condition")
        id_mapping = {}
        mapping.each { |k, v| id_mapping[k.id] = v.id }

        variable_values = {}
        @variable_types.each do |name, type|
            # var_node = @rule.match_graph.nodes.find { |node| node.label.value.is_a?(VariableLabelExpression) && node.label.value.name == name }
            var_node = @rule.match_graph.nodes.find { |node| node.label.value.variable? && node.label.value.name == name }
            variable_values[name] = mapping[var_node].label.value.value
        end

        evaluator = ConditionEvaluator.new(@rule.condition, @graph, id_mapping, variable_values)

        return evaluator.evaluate
    end

    def apply_node_change(rule_node_before, rule_node_after, graph_node_before, variables)
        graph_node_after = graph_node_before.clone


        removed_marks = rule_node_after.label&.markset.to_a.select { |mark| mark[0] == '¬' }.map { |demark| '#' + demark[1..-1] }
        added_marks = rule_node_after.label&.markset.to_a.select { |mark| mark[0] == '#' }

        new_markset = graph_node_before.label.markset.reject { |mark| removed_marks.include?(mark) }
        new_markset.push(*added_marks)
        new_markset.uniq!

        @log.trace("Updated markset")

        evaluator = LabelEvaluator.new(rule_node_after.label, graph_node_before.label, variables)
        new_label_value = evaluator.evaluate

        # puts "Evaluated label value:"
        # p new_label_value

        new_label_type = nil

        if new_label_value.nil?
            new_label_value = MatcherLabelExpression.new(:void)
        else
            new_label_value = LiteralLabelExpression.new(new_label_value)
            new_label_type = new_label_value.type
        end

        new_label = Label.new(new_label_value, new_label_type, new_markset)
        @log.trace("Updated label:")
        @log.trace(new_label.inspect)

        @log.trace("Updated label")

        return Node.new(graph_node_before.id, new_label)
    end

end
