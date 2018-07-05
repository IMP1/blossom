require_relative 'visitor'

class Printer < Visitor

    def initialize(statements)
        @statements = statements
        @programme_string = ""
    end

    def print_programme
        @statements.each do |stmt| 
            @programme_string += to_string(stmt) + "\n"
        end
        return @programme_string
    end

    def print_graph
        # Assuming @statements is a GraphExpression
        return to_string(@statements)
    end

    def to_string(obj)
        puts caller if obj.nil?
        obj.accept(self)
    end

    #------------#
    # Statements #
    #------------#

    def visit_RuleDefinitionStatement(stmt)
        str = "rule " + stmt.name + " " + to_string(stmt.match_graph) + " => " + to_string(stmt.result_graph)
        if stmt.condition
            str += " where " + to_string(stmt.condition)
        end
        if stmt.addendum
            str += " also " + to_string(stmt.addendum)
        end
        return str
    end

    def visit_ProcedureDefinitionStatement(stmt)
        return "proc " + stmt.name + " (" + stmt.statements.map { |stmt| to_string(stmt) }.join(" ") + ")"
    end

    def visit_LoopStatement(stmt)
        return "loop(" + to_string(stmt.statement) + ")"
    end

    def visit_TryStatement(stmt)
        return "try(" + to_string(stmt.statement) + ")"
    end

    def visit_IfStatement(stmt)
        str = "if(" + to_string(stmt.condition) + " : " + to_string(stmt.then_stmt)
        if !stmt.else_stmt.nil?
            str += " : " + to_string(stmt.else_stmt)
        end
        return str + ")"
    end

    def visit_WithStatement(stmt)
        str = "with(" + to_string(stmt.condition) + " : " + to_string(stmt.then_stmt)
        if !stmt.else_stmt.nil?
            str += " : " + to_string(stmt.else_stmt)
        end
        return str + ")"
    end

    def visit_SequenceStatement(stmt)
        str = "("
        str += stmt.statements.map { |s| to_string(s) }.join(" ")
        return str + ")"
    end

    def visit_ChoiceStatement(stmt)
        str = "{"
        str += stmt.statements.map { |s| to_string(s) }.join(", ")
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

    def visit_GraphExpression(expr)
        return "[\n" + expr.nodes.map { |n| to_string(n) }.join(",\n") + "\n|\n" + expr.edges.map {|e| to_string(e) }.join(",\n") + "\n]"
    end

    def visit_NodeExpression(expr)
        return expr.id.to_s + " " + to_string(expr.label)
    end

    def visit_EdgeExpression(expr)
        return expr.source_id.to_s + "->" + expr.target_id.to_s + " " +to_string(expr.label)
    end

    def visit_LabelExpression(expr)
        value = expr.value.nil? ? "" : to_string(expr.value)
        return "(" + value + " [" + expr.markset.map { |m| to_string(m) }.join(", ") + "])"
    end

    def visit_EmptyLabelExpression(expr)
        return "empty"
    end

    def visit_VoidLabelValueExpression(expr)
        return "void"
    end

    def visit_AnyLabelValueExpression(expr)
        return "*"
    end

    def visit_MissingLabelValueExpression(expr)
        return "<missing>"
    end

    def visit_LiteralExpression(expr)
        return expr.value.to_s
    end

    def visit_VariableExpression(expr)
        return expr.name
    end

    def visit_MarkExpression(expr)
        return expr.value
    end

    def visit_UnaryOperatorExpression(expr)
        right = to_string(expr.operand)
        case expr.operator.name
        when :MINUS
            return "-" + right
        when :NOT, :EXCLAMATION
            return "!" + right
        end
        puts "Unrecognised unary operator"
        p expr
        raise "Unrecognised unary operator"
    end

    def visit_BinaryOperatorExpression(expr)
        left = to_string(expr.left)
        right = to_string(expr.right)
        case expr.operator.name
        when :MINUS
            return left + " - " + right
        when :PLUS
            return left + " + " + right
        when :ASTERISK
            return left + " * " + right
        when :STROKE
            return left + " / " + right
        when :PERCENT
            return left + " % " + right
        when :CARET
            return left + " ^ " + right

        when :AMPERSAND, :AND
            return left + " & " + right
        when :PIPE, :OR
            return left + " | " + right

        when :EQUAL
            return left + " = " + right
        when :NOT_EQUAL
            return left + " ≠ " + right

        when :LESS
            return left + " < " + right
        when :LESS_EQUAL
            return left + " ≤ " + right
        when :GREATER
            return left + " > " + right
        when :GREATER_EQUAL
            return left + " ≥ " + right

        when :BEGINS_WITH
            return left + " ^ " + right
        when :ENDS_WITH
            return left + " $ " + right
        when :CONTAINS
            return left + " ⊃ " + right

        end
        puts "Unrecognised binary operator"
        p expr
        raise "Unrecognised binary operator"
    end

    def visit_FunctionCallExpression(expr)
        return ""
    end

    def visit_GroupingExpression(expr)
        return ""
    end

    #-----------------------#
    # Condition Expressions #
    #-----------------------#



    #---------------------#
    # Addendum Statements #
    #---------------------#




end