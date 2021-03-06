require_relative 'visitor'

class Statement 
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

    def to_s
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

    def initialize(procedure_token, proc_name, statements)
        super(procedure_token)
        @name = proc_name
        @statements = statements
    end

end

class LoopStatement < Statement

    attr_reader :statement

    def initialize(token, statement)
        super(token)
        @statement = statement
    end

    def to_s
        return statement.to_s + "!"
    end

end

class TryStatement < Statement

    attr_reader :statement

    def initialize(token, statement)
        super(token)
        @statement = statement
    end

    def to_s
        return "try(#{@statement.to_s})"
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

    def to_s
        str = "if(#{@condition.to_s} : #{@then_stmt.to_s}"
        str += " : " + @else_stmt.to_s if !@else_stmt.nil?
        return str + ")"
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

    def to_s
        str = "if(#{@condition.to_s} : #{@then_stmt.to_s}"
        str += " : " + @else_stmt.to_s if !@else_stmt.nil?
        return str + ")"
    end

end

class SequenceStatement < Statement

    attr_reader :statements

    def initialize(token, statements)
        super(token)
        @statements = statements
    end

    def to_s
        return @statements.map { |s| s.to_s }.join(" ")
    end 

end

class ChoiceStatement < Statement

    attr_reader :statements

    def initialize(token, statements)
        super(token)
        @statements = statements
    end

    def to_s
        return "{" + @statements.map { |s| s.to_s }.join(", ") + "}"
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

    def to_s
        return @name
    end

end

class ProcedureApplicationStatement < Statement

    attr_reader :name

    def initialize(token, name)
        super(token)
        @name = name
    end

    def to_s
        return @name
    end

end

class ProcedureStatement < Statement

    attr_reader :name

    def initialize(token, name)
        super(token)
        @name = name
    end

end
