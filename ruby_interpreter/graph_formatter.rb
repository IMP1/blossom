class GraphFormatter

    def self.format(graph, format_type)
        case format_type
        when :blossom
            return blossom_graph(graph)
        when :dot
            return dot_graph(graph)
        else
            raise "Unsupported graph format type #{format_type.to_s}."
        end
    end

    def self.blossom_graph(graph)
        return ""
        # TODO: do
        # return graph.join("\n")
    end

    def self.dot_graph(graph)
        # TODO: do
    end

end