require_relative 'objects/label_value_expression'

class GraphFormatter

    def self.format(graph, format_type)
        case format_type
        when :blossom
            return blossom_graph(graph)
        when :dot
            return dot_graph(graph)
        when :graph_ml
            return graph_ml_graph(graph)
        else
            raise "Unsupported graph format type #{format_type.to_s}."
        end
    end

    #---------#
    # Blossom #
    #---------#

    def self.blossom_graph(graph)
        nodes = graph.nodes.map { |n| "\t" + blossom_node(n) }.join(",\n")
        edges = graph.edges.map { |e| "\t" + blossom_edge(e) }.join(",\n")
        return "[\n" + nodes + "\n|\n" + edges + "\n]"
    end

    def self.blossom_node(node)
        str = node.id.to_s
        if !node.label.value.nil?
            str += " (" + blossom_label(node.label) + ")"
        end
        return str
    end

    def self.blossom_edge(edge)
        str = edge.source_id.to_s + " -> " + edge.target_id.to_s
        if !edge.label.value.nil?
            str += " (" + blossom_label(edge.label) + ")"
        end
        return str
    end

    def self.blossom_label(label)
        return [label.value.to_s, *label.markset].join(", ")
    end

    #----------------#
    # Dot / GraphViz #
    #----------------#

    def self.dot_graph(graph)
        # https://www.graphviz.org/doc/info/lang.html
        nodes = graph.nodes.map { |n| "\t" + dot_node(n) }.join("\n")
        edges = graph.edges.map { |e| "\t" + dot_edge(e) }.join("\n")
        return "digraph G {\n" + nodes + "\n" + edges + "\n}"
    end

    def self.dot_node(node)
        str = node.id.to_s
        if !node.label.value.nil?
            str += " [label=\"" + blossom_label(node.label) + "\"]"
        end
        return str + ";"
    end

    def self.dot_edge(edge)
        str = edge.source_id.to_s + " -> " + edge.target_id.to_s
        if !edge.label.value.nil?
            str += " [label=\"" + blossom_label(edge.label) + "\"]"
        end
        return str + ";"
    end

    def self.dot_label(label)
        return label.value.to_s
    end

    #---------#
    # GraphML #
    #---------#

    def self.graph_ml_graph(graph)
        header = <<~HEREDOC
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns 
                                     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
        HEREDOC
        header += LiteralLabelExpression::TYPES.map do |value_type|
            type = case value_type
            when :int
                "int"
            when :string
                "string"
            when :real
                "double"
            when :rational
                "double"
            when :bool
                "boolean"
            end
            "\t<key id=\"label_#{value_type.to_s}\" for=\"all\" attr.name=\"label_value\" attr.type=\"#{type}\"/>"
        end.join("\n")

        nodes = graph.nodes.map { |n| "\t\t" + graph_ml_node(n) }.join("\n")
        edges = graph.edges.map.with_index { |e, i| "\t\t" + graph_ml_edge(e, i) }.join("\n")
        graph = "\n\t<graph id=\"G\" edgedefault=\"directed\">\n" + nodes + "\n" + edges + "\n\t</graph>"
        footer = "\n</graphml>"
        return header + graph + footer
    end

    def self.graph_ml_node(node)
        puts "GraphML node:"
        str = "<node id=\"n#{node.id}\""
        if !node.label.value.nil?
            str += ">\n\t\t\t" + graph_ml_label(node.label)
            str += "\n\t\t</node>"
        else
            str += "/>"
        end
        return str
    end

    def self.graph_ml_edge(edge, edge_index)
        puts "GraphML edge:"
        str = "<edge id=\"e#{edge_index}\" source=\"n#{edge.source_id}\" target=\"n#{edge.target_id}\""
        if !edge.label.value.nil?
            str += ">\n\t\t\t" + graph_ml_label(edge.label)
            str += "\n\t\t</edge>"
        else
            str += "/>"
        end
        return str
    end

    def self.graph_ml_label(label)
        value = label.value
        value = value.to_f if value.is_a?(Rational)
        return "<data key=\"label_#{label.type.to_s}\">#{value.to_s}</data>"
    end

end