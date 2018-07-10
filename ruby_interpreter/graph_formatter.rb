require_relative 'objects/label_value_expression'
require_relative 'objects/graph'

class GraphFormatter

    Colour = Struct.new(:r, :g, :b) do
        def to_hex
            return "#%02x%02x%02x" % [r, g, b]
        end
    end

    COLOURS = {
        '#red'  => '#ff0000',
        '#lime' => '#00ff00',
        '#blue' => '#0000ff',
        # TODO: [1.0.0] add more named colours
    }

    # options
    #     keep_rationals:  boolean
    #     colour_strategy: [:ignore, :merge, :first]
    def self.format(graph, format_type, options=nil)
        options ||= {}
        @@options = options
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

    #-----------#
    # Utilities #
    #-----------#

    def self.get_colours(object)
        return object.label.markset.to_a
                .select {|m| m =~ /^#(?:[0-9a-fA-F]{3}){1,2}$/ || COLOURS.has_key?(m) }
                .map { |c| COLOURS.has_key?(c) ? COLOURS[c] : c }
                .map { |c| c.length == 4 ? '#' + c[1]*2 + c[2]*2 + c[3]*2 : c }
                .map { |c| c.match(/#(.{2})(.{2})(.{2})/)[1..-1].map {|h| h.to_i(16)} }
                .map { |c| Colour.new(*c) }
    end

    def self.add_colours(colours)
        return colours.reduce(Colour.new(255, 255, 255)) {|sum, c| Colour.new( sum.r * c.r / 255.0, sum.g * c.g / 255.0, sum.b * c.b / 255.0 ) }
    end

    def self.add_colours(colours)
        return colours.reduce(Colour.new(0, 0, 0)) {|sum, c| Colour.new(sum.r + c.r, sum.g + c.g, sum.b + c.b) }
    end

    #---------#
    # Blossom #
    #---------#

    def self.blossom_graph(graph)
        return "[INVALID]" if graph == Graph::INVALID
        nodes = graph.nodes.map { |n| "\t" + blossom_node(n) }.join(",\n")
        edges = graph.edges.map { |e| "\t" + blossom_edge(e) }.join(",\n")
        return "[\n" + nodes + "\n|\n" + edges + "\n]"
    end

    def self.blossom_node(node)
        str = node.id.to_s
        label = blossom_label(node.label)
        str += " (#{label})" if !label.empty?
        return str
    end

    def self.blossom_edge(edge)
        str = edge.source_id.to_s + " -> " + edge.target_id.to_s
        label = blossom_label(edge.label)
        str += " (#{label})" if !label.empty?
        return str
    end

    def self.blossom_label(label)
        return "" if label.value.nil?
        val = label.value.to_s
        val = nil if label.value.is_a?(MatcherLabelExpression) && label.value.keyword == :void
        val = label.value.to_f.to_s if label.value.is_a?(Rational) &&
        val = '"' + val + '"' if label.value.type == :string
        return [val, *label.markset].compact.join(", ")
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
            label = []
            label.push("label=\"#{dot_label(node.label)}\"")
            label.push(dot_colour(node))
            str += " [" + label.compact.join(" ") + "]"
        end
        return str + ";"
    end

    def self.dot_edge(edge)
        str = edge.source_id.to_s + " -> " + edge.target_id.to_s
        if !edge.label.value.nil?
            str += " [label=\"" + dot_label(edge.label) + "\"" + dot_colour(edge) + "]"
        end
        dot_colour(edge)
        return str + ";"
    end

    def self.dot_label(label)
        return label.value.to_s
    end

    def self.dot_colour(obj)
        return nil if @@options[:colour_strategy] == :ignore
        c = get_colours(obj)
        return nil if c.empty?
        case @@options[:colour_strategy]
        when :merge
            c = add_colours(c)
        when :first
            c = c.first
        end
        return "color=\"#{c.to_hex}\""
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
        if @@options[:colour_strategy] != :ignore
            header += "\n\t<key id=\"label_colour\" for=\"all\" attr.name=\"color\" attr.type=\"string\"/>\n"
        end

        nodes = graph.nodes.map { |n| "\t\t" + graph_ml_node(n) }.join("\n")
        edges = graph.edges.map.with_index { |e, i| "\t\t" + graph_ml_edge(e, i) }.join("\n")
        graph = "\n\t<graph id=\"G\" edgedefault=\"directed\">\n" + nodes + "\n" + edges + "\n\t</graph>"
        footer = "\n</graphml>"
        return header + graph + footer
    end

    def self.graph_ml_node(node)
        puts "GraphML node:"
        str = "<node id=\"n#{node.id}\""
        label = []
        label.push(graph_ml_label(node.label))
        label.push(graph_ml_colour(node))
        label.compact!
        if label.empty?
            str += " />"
        else
            str += ">\n"
            str += label.map { |x| "\t\t\t" + x }.join("\n")
            str += "\n\t\t</node>"
        end
        return str
    end

    def self.graph_ml_edge(edge, edge_index)
        puts "GraphML edge:"
        str = "<edge id=\"e#{edge_index}\" source=\"n#{edge.source_id}\" target=\"n#{edge.target_id}\""
        label = []
        label.push(graph_ml_label(edge.label))
        label.push(graph_ml_colour(edge))
        label.compact!
        if label.empty?
            str += " />"
        else
            str += ">\n"
            str += label.map { |x| "\t\t\t" + x }.join("\n")
            str += "\n\t\t</edge>"
        end

        return str
    end

    def self.graph_ml_label(label)
        return nil if label.value.nil?
        value = label.value
        type  = label.type
        if value.is_a?(Rational)
            value = value.to_f 
            type  = "double"
        end
        type == "boolean" if type == :bool
        return "<data key=\"label_#{label.type.to_s}\">#{value.to_s}</data>"
    end

    def self.graph_ml_colour(obj)
        return nil if @@options[:colour_strategy] == :ignore
        c = get_colours(obj)
        return nil if c.empty?
        case @@options[:colour_strategy]
        when :merge
            c = add_colours(c)
        when :first
            c = c.first
        end

        return "<data key=\"label_colour\">#{c.to_hex}</data>"
    end

end