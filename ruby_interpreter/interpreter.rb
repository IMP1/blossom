require_relative 'main'
require_relative 'error'
require_relative 'visitor'


class Interpreter < Visitor

    def initialize(host_graph, statements)
        @host_graph = host_graph
        @statements = statements
        @current_graph = host_graph
    end

    def interpret
        begin
            @statements.each { |stmt| execute(stmt) }
        rescue BlossomRuntimeError => e
            Runner.runtime_error(e)
        end
        return @current_graph
    end

    def execute(stmt)
        stmt.accept(self)
    end

    def evaluate(expr)
        expr.accept(self)
    end

    #------------#
    # Statements #
    #------------#

    def visit_RuleDefinitionStatement(stmt)

    end

    def visit_ProcedureDefinitionStatement(stmt)

    end

    def visit_LoopStatement(stmt)

    end

    def visit_TryStatement(stmt)

    end

    def visit_IfStatement(stmt)

    end

    def visit_WithStatement(stmt)

    end

    def visit_SequenceStatement(stmt)

    end

    def visit_ChoiceStatement(stmt)

    end

    def visit_NoopStatement(stmt)

    end

    def visit_InvalidStatement(stmt)

    end

    def visit_RuleApplicationStatement(stmt)

    end

    def visit_ProcedureApplicationStatement(stmt)

    end

    #-------------#
    # Expressions #
    #-------------#    

    def visit_GraphExpression(expr)
        
    end

    def visit_NodeExpression(expr)
        
    end

    def visit_EdgeExpression(expr)
        
    end

    def visit_LabelExpression(expr)
        
    end

    def visit_EmptyLabelExpression(expr)
        
    end

    def visit_VoidLabelValueExpression(expr)
        
    end

    def visit_AnyLabelValueExpression(expr)
        
    end

    def visit_LiteralExpression(expr)
        
    end

    def visit_VariableExpression(expr)
        
    end

    def visit_MarkExpression(expr)
        
    end

    def visit_BinaryOperatorExpression(expr)
        
    end

    def visit_FunctionCallExpression(expr)
        
    end


end