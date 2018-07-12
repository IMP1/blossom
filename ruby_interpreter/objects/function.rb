class Function

    attr_reader :name
    attr_reader :return_type
    attr_reader :parameter_types

    def initialize(name, return_type, parameter_types, &block)
        @name = name
        @return_type = return_type
        @parameter_types = parameter_types
        @block = block
    end

    def call(evaluator, args)
        return @block.call(evaluator, args)
    end

    def self.in
        # Takes an ID of a node and returns how many edges have that node as their target.
        # (the number of edges coming 'in' to the node).
        return Function.new("in", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            in_edges = evaluator.graph.edges.select { |e| e.target_id == graph_node_id }
            in_edges.count
        end
    end

    def self.out
        # Takes an ID of a node and returns how many edges have that node as their source.
        # (the number of edges going 'out' from the node).
        return Function.new("out", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            out_edges = evaluator.graph.edges.select { |e| e.source_id == graph_node_id }
            out_edges.count
        end
    end

    def self.incident
        # Takes an ID of a node and returns how many edges have that node as their source or their target.
        # (the number of edges incident to the node).
        return Function.new("incident", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            adj_edges = evaluator.graph.edges.select { |e| e.source_id == graph_node_id || e.target_id == graph_node_id }
            adj_edges.count
        end
    end

    def self.edge
        # Takes two node IDs and returns how many edges there are that have the first as their source and the second as their target.
        # (the number of edges from the first node to the second).
        return Function.new("edge", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| e.source_id == source_node_id && e.target_id == target_node_id }
            edge_count
        end
    end

    def self.adj
        # Takes two node IDs and returns how many edges there are that have either the first or the second as either their source or their target.
        # (the number of edges between the two nodes).
        return Function.new("adj", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| (e.source_id == source_node_id && e.target_id == target_node_id) ||
                                                           (e.source_id == target_node_id && e.target_id == source_node_id) }
            edge_count
        end
    end

    def self.edge?
        # Takes two node IDs and returns true if there is at least one edge that has the first as its source and the second as its target.
        # (whether there's an edge from the first node to the second).
        return Function.new("edge?", :bool, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| e.source_id == source_node_id && e.target_id == target_node_id }
            edge_count > 0
        end
    end

    def self.adj?
        # Takes two node IDs and returns true if there is at least one edge that has the first or the second as its source or its target.
        # (whether there's an edge between the two nodes).
        return Function.new("adj?", :bool, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| (e.source_id == source_node_id && e.target_id == target_node_id) ||
                                                           (e.source_id == target_node_id && e.target_id == source_node_id) }
            edge_count > 0
        end
    end

    def self.distinct?
        return Function.new("distinct?", :bool, [:int, :int]) do |evaluator, args|
            mappings = evaluator.mapping.select {|k, v| args.include?(k) }
            mappings[args[0]] != mappings[args[1]]
        end
    end

    def self.str
        # Takes any value and converts it to a string.
        return Function.new("str", :string, [:any]) do |evaluator, args|
            args[0].to_s
        end
    end

    def self.int
        # Takes any value and converts it to an integer.
        return Function.new("int", :int, [:any]) do |evaluator, args|
            args[0].to_i
        end
    end

    def self.head
        # Returns the first character of a string
        return Function.new("head", :string, [:string]) do |evaluator, args|
            args[0][0]
        end
    end

    def self.tail
        # Returns all but the first character of a string
        return Function.new("tail", :string, [:string]) do |evaluator, args|
            args[0][1..-1]
        end
    end

    def self.len
        # Returns the length of a string
        return Function.new("len", :int, [:string]) do |evaluator, args|
            args[0].length
        end
    end

end