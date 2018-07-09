require_relative 'visitor'

class Statement 
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

    def source
        return token.lexeme
    end

end


class RuleDefinitionStatement < Statement

    attr_reader :name
    attr_reader :parameters
    attr_reader :match_graph
    attr_reader :result_graph
    attr_reader :condition
    attr_reader :addendum

    def initialize(rule_token, rule_name, parameters, match_graph, result_graph, condition, addendum)
        super(rule_token)
        @name = rule_name
        @parameters = parameters
        @match_graph = match_graph
        @result_graph = result_graph
        @condition = condition
        @addendum = addendum
    end

end

class ProcedureDefinitionStatement < Statement

    attr_reader :name
    attr_reader :statements

    def initialize(procedure_name_token, statements)
        super(procedure_name_token)
        @name = procedure_name_token.lexeme
        @statements = statements
    end

end

class LoopStatement < Statement

    attr_reader :statement

    def initialize(token, statement)
        super(token)
        @statement = statement
    end

    def source
        return statement.source + token.lexeme
    end

end

class TryStatement < Statement

    attr_reader :statement

    def initialize(token, statement)
        super(token)
        @statement = statement
    end

end

class IfStatement < Statement

    attr_reader :condition
    attr_reader :then_stmt
    attr_reader :else_stmt

    def initialize(token, condition, then_stmt, else_stmt)
        super(token)
        @condition = condition
        @then_stmt = then_stmt
        @else_stmt = else_stmt
    end

end

class WithStatement < Statement

    attr_reader :condition
    attr_reader :then_stmt
    attr_reader :else_stmt

    def initialize(token, condition, then_stmt, else_stmt)
        super(token)
        @condition = condition
        @then_stmt = then_stmt
        @else_stmt = else_stmt
    end

end

class SequenceStatement < Statement

    attr_reader :statements

    def initialize(token, statements)
        super(token)
        @statements = statements
    end

end

class ChoiceStatement < Statement

    attr_reader :statements

    def initialize(token, statements)
        super(token)
        @statements = statements
    end
end

class NoopStatement < Statement

    def initialize(token)
        super(token)
    end
end

class InvalidStatement < Statement

    def initialize(token)
        super(token)
    end
end

class RuleApplicationStatement < Statement

    attr_reader :name

    def initialize(token, name)
        super(token)
        @name = name
    end

end


class ProcedureStatement < Statement

    attr_reader :name

    def initialize(token, name)
        super(token)
        @name = name
    end

end


class ProcedureApplicationStatement < Statement

    attr_reader :name

    def initialize(token, name)
        super(token)
        @name = name
    end

end