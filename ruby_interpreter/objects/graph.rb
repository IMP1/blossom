require_relative 'node'
require_relative 'edge'

class Graph

    INVALID = Graph.new

    attr_reader :nodes
    attr_reader :edges
    attr_reader :variables

    def initialize(nodes, edges, variables)
        @nodes = nodes
        @edges = edges
        @variables = variables
    end 

    def to_s
        str = "[\n"
        @nodes.each { |n| str += "  " + n.to_s + "\n" }
        str += "|\n"
        @edges.each { |e| str += "  " + e.to_s + "\n" }
        return str + "]\n"
    end

    def remove_node(node_id)
        @nodes.reject! { |n| n.id == node_id }
    end

    def add_node(node)
        new_node_id = @nodes.size
        while @nodes.any? { |n| n.id == new_node_id }
            new_node_id = new_node_id + 1
        end
        new_node = Node.new(new_node_id, node.label.clone)
        @nodes.push(new_node)
        return new_node
    end

    def update_node(node_id, new_label)
        @nodes.first { |n| n.id == node_id}.label = new_label
    end

end