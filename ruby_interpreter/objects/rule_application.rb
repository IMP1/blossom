require_relative '../log'
require_relative 'graph'

class RuleApplication

    def initialize(rule, graph)
        @log = Log.new("RuleApplication")
        @log.set_level(Log::ALL)
        @rule = rule
        @graph = graph
    end

    def attempt
        rule = @rule
        graph = @graph
        @log.trace("Attempting to apply a rule.")

        @log.trace("Current Host Graph:")
        @log.trace(@graph.to_s)
        @log.trace("Rule Match Graph:")
        @log.trace(@rule.match_graph.to_s)
        @log.trace("Rule Result Graph:")
        @log.trace(@rule.result_graph.to_s)

        added_rule_nodes = @rule.result_graph.nodes.select { |node| 
            !@rule.match_graph.nodes.any? { |n| node.id == n.id }
        }
        removed_rule_nodes = @rule.match_graph.nodes.select { |node| 
            !@rule.result_graph.nodes.any? { |n| node.id == n.id }
        }
        @log.trace("#{added_rule_nodes.size} nodes to add.")
        @log.trace("#{removed_rule_nodes.size} nodes to remove.")

        possible_matches = {}

        @rule.match_graph.nodes.each do |rule_node|
            possible_matches[rule_node] = @graph.nodes.select { |graph_node| 
                nodes_match?(rule_node, graph_node, @rule.match_graph.edges, @graph.edges) 
            }
        end

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

        removed_rule_nodes.each do |removed_rule_node|
            possible_matches = possible_matches.reject do |mapping| 
                puts "Adj Graph = " + adjacent_graph_edge_count[mapping[removed_rule_node]].to_s
                puts "Adj Rule = "  + adjacent_rule_edge_count[removed_rule_node].to_s
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

        # TODO: decide on whether different rule match_graph nodes can be mapped to the same graph node.
        #       rule r [ 1, 2 ] => [ 1, 2 | 1->2 ];
        #       applying r on [ 1(3), 2(1) ]
        #       could yield any of these:
        #       [ 1(3), 2(1) | 1->2 ]
        #       [ 1(3), 2(1) | 2->1 ]
        #       [ 1(3), 2(1) | 1->1 ]    \_ Should these last two be valid? If so, should there be a way
        #       [ 1(3), 2(1) | 2->2 ]    /  of specifying that they must be different (in the where condition maybe?)

        # TODO: handle matching edges between possible node mappings.



        puts "\nPossible Matches:"
        possible_matches.each do |pm|
            pm.each do |k, v|
                print "#{k.id} => #{v.id}"
                print ", "
            end
            print "\n"
        end

        # TODO: check rule condition with possible mappings

        # TODO: actually apply mapping (add, remove, and update nodes as necessary.)

        # TODO: execute addendum

        return Graph::INVALID
    end

    def nodes_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        return false if !label_value_match?(rule_node.label, graph_node.label)
        return false if !markset_match?(rule_node.label, graph_node.label)
        return false if !adj_edges_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        # ...
        return true
    end

    # Rule node labels have a label_value_expression as their value, and an array of strings as their markset
    # Graph node labels have, as their value, either nil (for `void`) or a literal value. 
    # They may also have nil for their whole label if it is not given (for `empty`).
    def label_value_match?(rule_label, graph_label)
        return true if rule_label.nil?
        return true if rule_label.value.nil?

        if rule_label.value.is_a?(Matcher) && rule_label.value.keyword == :void
            @log.trace("Checking for void")
            return graph_node.label.value == nil
        end
        if rule_label.value.variable?
            @log.trace("Checking type")
            @log.trace(rule_label.value.type.inspect)
            @log.trace(graph_label.type.inspect)
            return rule_label.value.type == graph_label.type
        end
        if rule_label.value.is_a?(Literal)
            @log.trace("Checking values")
            @log.trace(rule_label.value.value.inspect)
            @log.trace(graph_label.value.inspect)
            return rule_label.value.value == graph_label.value
        end
        puts "Unaccounted for label value pairing: "
        p rule_label
        p graph_label
        raise "Unaccounted-for label value pairing."
    end

    def markset_match?(rule_label, graph_label)
        return true if rule_label.nil?
        return true if rule_label.markset.nil?

        if rule_label.markset.empty?
            return graph_label.markset.empty?
        end
        if rule_label.markset.select { |m| m[0] == "#" }
                             .any? { |m| !graph_label.markset.include?(m) }
            return false
        end
        if rule_label.markset.select { |m| m[0] == "¬" }
                             .any? { |m| graph_label.markset.include?(m) }
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

end

#-----------------------------------------------------------#
#
# Find match of nodes
# make note of variable values before rule application
# add new nodes, remove old nodes
# change labels where needbe
# check graph validity
# 
#


