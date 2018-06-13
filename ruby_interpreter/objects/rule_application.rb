module RuleApplication

    def self.attempt(rule, graph)
        puts "\nAttempting to apply a rule."
        p rule
        p graph
        puts "\n\n"

        possible_matches = {}

        rule.match_graph.nodes.each do |rule_node|
            possible_matches[rule_node] = graph.nodes.select { |graph_node| 
                nodes_match?(rule_node, graph_node, rule.match_graph.edges, graph.edges) 
            }
        end

        puts possible_matches

    end

    def self.nodes_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        return false if !label_value_match?(rule_node.label, graph_node.label)
        puts "match label vale"
        return false if !markset_match?(rule_node.label, graph_node.label)
        puts "match label marks"
        return false if !adj_edges_match?(rule_node, graph_node, rule_graph_edges, graph_edges)
        puts "match edges"
        # ...
        return true
    end

    # Rule node labels have a label_value_expression as their value, and an array of strings as their markset
    # Graph node labels have, as their value, either nil (for `void`) or a literal value. 
    # They may also have nil for their whole label if it is not given (for `empty`).
    def self.label_value_match?(rule_label, graph_label)
        return true if rule_label.nil?
        return true if rule_label.value.nil?

        if rule_label.value.is_a?(Matcher) && rule_label.value.keyword == :void
            puts "Checking for void"
            return graph_node.label.value == nil
        end
        if rule_label.value.variable?
            puts "Checking type"
            p rule_label.value.type
            p graph_label.type
            return rule_label.value.type == graph_label.type
        end
        if rule_label.value.is_a?(Literal)
            puts "Checking values"
            return rule_label.value.value == graph_label.value
        end
        puts "Unaccounted for label value pairing: "
        p rule_label
        p graph_label
        raise "Unaccounted-for label value pairing."
    end

    def self.markset_match?(rule_label, graph_label)
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

    def self.adj_edges_match?(rule_node, graph_node, rule_edges, graph_edges)
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


