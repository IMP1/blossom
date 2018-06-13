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

        possible_matches = {}

        rule.match_graph.nodes.each do |rule_node|
            possible_matches[rule_node] = graph.nodes.select { |graph_node| 
                nodes_match?(rule_node, graph_node, rule.match_graph.edges, graph.edges) 
            }
        end

        # TODO: Create sets of possible permutations, rather than just possiblities for each node.
        #       This, I think, is the next step /after/ working out possibilities for each node.
        #       Or maybe just create all permutations (n*m) and check which are possible?
        #       This is probably the only challege left to do, and I reckon it's going to be the 
        #       most intensive part of the interpreter.

        # IDEA: Maybe go through the first node in the rule graph, and get all its possible matches.
        #       Then go through all of the those possible matches, and try to add the matches of the 
        #       second node (and so on). So you're left with an array of hashmaps.
        #       After first pass:
        #       possible_matches = [ {1=>1}, {1=>2} ]
        #       After second pass (using first pass matches):
        #       possible_matches = [ {1=>1, 2=>2}, {1=>2, 2=>3} ]
        #       This stops the current problem of finding the possible matches:
        #       {1=>[1, 2], 2=>[2, 3]} without accounting for the combinations of these matches.

        @log.trace("Rule Match Graph:")
        @log.trace(rule.match_graph.to_s)
        @log.trace("Rule Result Graph:")
        @log.trace(rule.result_graph.to_s)

        added_rule_nodes = rule.result_graph.nodes.select { |node| 
            !rule.match_graph.nodes.any? { |n| node.id == n.id }
        }
        removed_rule_nodes = rule.match_graph.nodes.select { |node| 
            !rule.result_graph.nodes.any? { |n| node.id == n.id }
        }

        adjacent_edge_count = {}
        graph.nodes.each do |n|
            adjacent_edge_count[n] = graph.edges.count { |e| e.source_id == n.id || e.target_id == n.id }
        end
        rule.match_graph.nodes.each do |n|
            adjacent_edge_count[n] = graph.edges.count { |e| e.source_id == n.id || e.target_id == n.id }
        end

        # TODO: Any removed nodes must not be incident to any edges not in the rule.
        #       (the host graph's node must not have a higher incident value than the initial graph's node).
        #       Otherwise it will not satisfy the DANGLING CONDITION.



        removed_rule_nodes.each do |rule_node|
            possible_matches[rule_node] = possible_matches[rule_node].select { |graph_node|
                p adjacent_edge_count[graph_node];
                p adjacent_edge_count[rule_node];
                adjacent_edge_count[graph_node] <= adjacent_edge_count[rule_node]
            }
        end

        @log.trace("Adding #{added_rule_nodes.size} nodes.")
        @log.trace("Removing #{removed_rule_nodes.size} nodes.")

        puts "Rule Node | Graph Node Matches"
        possible_matches.each do |k, v|
            print " " + k.id.to_s.ljust(9) + "  "
            print v.empty? ? "--" : v[0].id
            print "\n"
            v[1..-1].each do |m|
                print " " * 12
                print m.id
                print "\n"
            end
        end

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


