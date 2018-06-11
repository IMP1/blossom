class Statement 

    attr_reader :token

    def initialize(token)
        @token = token
    end

end


class RuleDefinitionStatement < Statement

    attr_reader :parameters
    attr_reader :match_graph
    attr_reader :result_graph
    attr_reader :condition
    attr_reader :addendum

    def initialize(rule_name_token, parameters, match_graph, result_graph, condition, addendum)
        super(rule_name_token)
        @parameters = parameters
        @match_graph = match_graph
        @result_graph = result_graph
        @condition = condition
        @addendum = addendum
    end

end