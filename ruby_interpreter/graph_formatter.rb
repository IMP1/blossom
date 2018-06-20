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
        puts "Outputting Blossom Graph:"
        return "<blossom graph goes here>"
        # TODO: redo printer to be a /blossom/ printer (to output as they're inputted)
        # return graph.join("\n")
    end

    def self.dot_graph(graph)
        # https://en.wikipedia.org/wiki/DOT_(graph_description_language)
        puts "Outputting Dot Graph:"
        return "<dot graph goes here>"
        # TODO: add a dot printer to output valid dot graphs.
    end

end