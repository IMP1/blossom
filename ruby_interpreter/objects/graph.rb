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

end