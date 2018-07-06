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

    def self.node
        return Function.new("node", Node, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            graph_node = evaluator.graph.nodes.find { |n| n.id == graph_node_id }
            graph_node
        end
    end

    def self.in
        return Function.new("in", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            in_edges = evaluator.graph.edges.select { |e| e.target_id == graph_node_id }
            in_edges.count
        end
    end

    def self.out
        return Function.new("out", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            out_edges = evaluator.graph.edges.select { |e| e.source_id == graph_node_id }
            out_edges.count
        end
    end

    def self.incident
        return Function.new("incident", :int, [:int]) do |evaluator, args|
            rule_node_id = args[0]
            graph_node_id = evaluator.mapping[rule_node_id]
            adj_edges = evaluator.graph.edges.select { |e| e.source_id == graph_node_id || e.target_id == graph_node_id }
            adj_edges.count
        end
    end

    def self.edge
        return Function.new("edge", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| e.source_id == source_node_id && e.target_id == target_node_id }
            edge_count
        end
    end

    def self.adj
        return Function.new("adj", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| (e.source_id == source_node_id && e.target_id == target_node_id) ||
                                                           (e.source_id == target_node_id && e.target_id == source_node_id) }
            edge_count
        end
    end

    def self.edge?
        return Function.new("edge?", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| e.source_id == source_node_id && e.target_id == target_node_id }
            edge_count > 0
        end
    end

    def self.adj?
        return Function.new("adj?", :int, [:int, :int]) do |evaluator, args|
            source_node_id = evaluator.mapping[args[0]]
            target_node_id = evaluator.mapping[args[1]]
            edge_count = evaluator.graph.edges.count { |e| (e.source_id == source_node_id && e.target_id == target_node_id) ||
                                                           (e.source_id == target_node_id && e.target_id == source_node_id) }
            edge_count > 0
        end
    end

    def self.str
        return Function.new("str", :string, [:any]) do |evaluator, args|
            args[0].to_s
        end
    end

    def self.head
        return Function.new("head", :string, [:string]) do |evaluator, args|
            args[0][0]
        end
    end

    def self.tail
        return Function.new("tail", :string, [:string]) do |evaluator, args|
            args[0][1..-1]
        end
    end

    def self.len
        return Function.new("len", :int, [:string]) do |evaluator, args|
            args[0].length
        end
    end

end