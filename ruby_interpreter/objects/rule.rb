class Rule

    attr_reader :name
    attr_reader :parameters
    attr_reader :match_graph
    attr_reader :result_graph
    attr_reader :condition
    attr_reader :addendum

    def initialize(name, parameters, match_graph, result_graph, condition, addendum)
        @name = name
        @parameters = parameters
        @match_graph = match_graph
        @result_graph = result_graph
        @condition = condition
        @addendum = addendum
    end

end