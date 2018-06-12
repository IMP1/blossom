module RuleApplication

    def self.attempt(rule, graph)
        puts "\nAttempting to apply a rule."
        p rule
        p graph
        puts "\n\n"
    end

    def self.nodes_match?(rule_node, graph_node)
        return false if !label_value_match?(rule_node.label, graph_node.label)
        return false if !markset_match?(rule_node, graph_node)
        return false if !adj_edges_match?(rule_node, graph_node)
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
            return graph_node.label.value == nil
        end
        if rule_label.value.variable?
            return rule_label.value.type == graph_label.type
        end
        if rule_label.value.is_a?(Literal)
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


