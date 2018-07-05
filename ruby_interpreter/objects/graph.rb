require_relative 'node'
require_relative 'edge'

class Graph

    attr_reader :nodes
    attr_reader :edges
    attr_reader :variables

    def initialize(nodes, edges)
        @nodes = nodes
        @edges = edges
    end 

    def to_s
        return "invalid" if self == INVALID
        
        str = "[\n"
        @nodes.each { |n| str += "  " + n.to_s + "\n" }
        str += "|\n"
        @edges.each { |e| str += "  " + e.to_s + "\n" }
        return str + "]\n"
    end

    def remove_node(node_id)
        @nodes.reject! { |n| n.id == node_id }
    end

    def add_node(label)
        new_node_id = @nodes.size
        while @nodes.any? { |n| n.id == new_node_id }
            new_node_id = new_node_id + 1
        end
        new_node = Node.new(new_node_id, label.clone)
        @nodes.push(new_node)
        return new_node
    end

    def update_node(node_id, new_label)
        @nodes.find { |n| n.id == node_id }.label = new_label
    end

    def clone
        return Graph.new(
            @nodes.map { |node| node.clone },
            @edges.map { |node| node.clone },
        )
    end

    INVALID = Graph.new([], [])

end