require_relative 'visitor'

class Printer < Visitor

    def initialize(statements)
        @statements = statements
        @programme_string = ""
    end

    def print_programme
        @statements.each do |stmt| 
            @programme_string += print_statement(stmt) + "\n"
        end
        return @programme_string
    end

    def print_graph
        # Assuming @statements is a GraphExpression
        return print_expression(@statements)
    end

    def print_statement(stmt)
        stmt.accept(self)
    end

    def print_expression(expr)
        expr.accept(self)
    end

    #------------#
    # Statements #
    #------------#

    def visit_RuleDefinitionStatement(stmt)
        return "rule " + stmt.name
    end

    def visit_ProcedureDefinitionStatement(stmt)
        return "proc " + stmt.name
    end

    def visit_LoopStatement(stmt)
        return "loop(" + print_statement(stmt.statement) + ")"
    end

    def visit_TryStatement(stmt)
        return "try(" + print_statement(stmt.statement) + ")"
    end

    def visit_IfStatement(stmt)
        str = "if(" + print_statement(stmt.condition) + " : " + print_statement(stmt.then_stmt)
        if !stmt.else_stmt.nil?
            str += " : " + print_statement(stmt.else_stmt)
        end
        return str + ")"
    end

    def visit_WithStatement(stmt)
        str = "with(" + print_statement(stmt.condition) + " : " + print_statement(stmt.then_stmt)
        if !stmt.else_stmt.nil?
            str += " : " + print_statement(stmt.else_stmt)
        end
        return str + ")"
    end

    def visit_SequenceStatement(stmt)
        str = "("
        str += stmt.statements.map { |s| print_statement(s) }.join(" ")
        return str + ")"
    end

    def visit_ChoiceStatement(stmt)
        str = "{"
        str += stmt.statements.map { |s| print_statement(s) }.join(", ")
        return str + "}"
    end

    def visit_NoopStatement(stmt)
        return "noop"
    end

    def visit_InvalidStatement(stmt)
        return "invalid"
    end

    def visit_RuleApplicationStatement(stmt)
        return stmt.name
    end

    def visit_ProcedureApplicationStatement(stmt)
        return stmt.name
    end

    #-------------#
    # Expressions #
    #-------------#



end