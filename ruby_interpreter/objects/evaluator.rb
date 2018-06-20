require_relative '../visitor'

require_relative 'label'
require_relative 'label_value_expression'

class LabelEvaluator < Visitor

    def initialize(label, variables)
        @label = label
        @variables = variables
    end

    def evaluate
        if @label.nil?
            puts "Label is nil!!"
            puts caller
            raise "Label is nil."
        end
        if @label.value.nil?
            return nil
        end
        return evaluate_expression(@label.value)
    end

    def evaluate_expression(expr)
        return expr.accept(self)
    end

    #-------------#
    # Expressions #
    #-------------#

    def visit_Literal(expr)
        return expr.value
    end

    def visit_Variable(expr)
        if !@variables.has_key?(expr.name)
            raise "unrecognised variable '#{expr.name}'."
        end
        return @variables[expr.name]
    end

    def visit_Matcher(expr)
        puts "HRRRRRM"
    end

    def visit_UnaryOperator(expr)
        right = evaluate_expression(expr.operand)
        case expr.operator
        when :MINUS
            return -right
        when :NOT, :EXCLAMATION
            return !right
        end
        puts "Unrecognised unary operator"
        p expr
        raise "Unrecognised unary operator"
    end

    def visit_BinaryOperator(expr)
        left = evaluate_expression(expr.left)
        right = evaluate_expression(expr.right)
        case expr.operator
        when :MINUS
            return left - right
        when :PLUS
            puts "+ operator (either add, concatenate or xor?) in label"
            p left
            p right
            return left + right
        when :ASTERISK
            return left * right
        when :STROKE
            return left / right
        when :PERCENT
            return left % right
        when :CARET
            return left ** right

        when :AMPERSAND, :AND
            return left && right
        when :PIPE, :OR
            return left || right

        when :EQUAL
            return left == right
        when :NOT_EQUAL
            return left != right

        when :LESS
            return left < right
        when :LESS_EQUAL
            return left <= right
        when :GREATER
            return left > right
        when :GREATER_EQUAL
            return left >= right

        when :BEGINS_WITH
            return left.start_with?(right)
        when :ENDS_WITH
            return left.end_with?(right)
        when :CONTAINS
            return left.include?(right)

        end
        puts "Unrecognised binary operator"
        p expr
        raise "Unrecognised binary operator"
    end

    def visit_Group(expr)
        return evaluate_expression(expr.expression)
    end



end


class ConditionEvaluator < Visitor

    attr_reader :mapping
    attr_reader :graph
    attr_reader :variables

    def initialize(condition, graph, mapping, variables)
        @condition = condition
        @graph = graph
        @mapping = mapping
        @variables = variables
    end

    def evaluate
        return evaluate_expression(@condition)
    end

    def evaluate_expression(expr)
        return expr.accept(self)
    end

    #-------------#
    # Expressions #
    #-------------#

    def visit_Literal(expr)
        return expr.value
    end

    def visit_Variable(expr)
        if !@variables.has_key?(expr.name)
            raise "unrecognised variable '#{expr.name}'."
        end
        return @variables[expr.name]
    end

    def visit_UnaryOperatorExpression(expr)
        right = evaluate_expression(expr.operand)
        case expr.operator
        when :MINUS
            return -right
        when :NOT, :EXCLAMATION
            return !right
        end
        puts "Unrecognised unary operator"
        p expr
        raise "Unrecognised unary operator"
    end

    def visit_BinaryOperatorExpression(expr)
        left = evaluate_expression(expr.left)
        right = evaluate_expression(expr.right)
        case expr.operator
        when :MINUS
            return left - right
        when :PLUS
            puts "+ operator (either add, concatenate or xor?) in condition"
            p left
            p right
            return left + right
        when :ASTERISK
            return left * right
        when :STROKE
            return left / right
        when :PERCENT
            return left % right
        when :CARET
            return left ** right

        when :AMPERSAND, :AND
            return left && right
        when :PIPE, :OR
            return left || right

        when :EQUAL
            return left == right
        when :NOT_EQUAL
            return left != right

        when :LESS
            return left < right
        when :LESS_EQUAL
            return left <= right
        when :GREATER
            return left > right
        when :GREATER_EQUAL
            return left >= right

        when :BEGINS_WITH
            return left.start_with?(right)
        when :ENDS_WITH
            return left.end_with?(right)
        when :CONTAINS
            return left.include?(right)

        end
        puts "Unrecognised binary operator"
        p expr
        raise "Unrecognised binary operator"
    end

    def visit_Group(expr)
        return evaluate_expression(expr.expression)
    end

    def visit_FunctionCall(expr)
        args = expr.arguments.map { |a| evaluate_expression(a) }
        return expr.function.call(self, args)
    end

end


class AddendumExecutor < ConditionEvaluator

    def initialize(addendum, graph, mapping, variables)
        @addendum = addendum
        @graph = graph
        @mapping = mapping
        @variables = variables
    end

    def execute
        return execute_statement(@addendum)
    end

    def execute_statement(expr)
        return expr.accept(self)
    end

    #------------#
    # Statements #
    #------------#

    def visit_ProcedureCall(stmt)
        args = stmt.arguments.map { |a| evaluate_expression(a) }
        stmt.procedure.call(self, args)
    end

end