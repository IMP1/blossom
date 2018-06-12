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

end