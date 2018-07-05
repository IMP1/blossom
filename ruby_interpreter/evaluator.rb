require_relative 'visitor'

require_relative 'objects/label'
require_relative 'objects/label_value_expression'

class LabelEvaluator < Visitor

    def initialize(label, old_label, variables)
        @label = label
        @old_label = old_label
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

    def visit_LiteralLabelExpression(expr)
        return expr.value
    end

    def visit_VariableLabelExpression(expr)
        if !@variables.has_key?(expr.name)
            raise "Unrecognised variable '#{expr.name}'."
        end
        return @variables[expr.name]
    end

    def visit_MatcherLabelExpression(expr)
        case expr.keyword
        when :void
            return nil
        end
        raise "A normal graph (one not in a rule) cannot have void/empty/unmarked keywords. Leave the label empty to achieve the same effect."
    end

    def visit_UnaryOperatorLabelExpression(expr)
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

    def visit_BinaryOperatorLabelExpression(expr)
        left = evaluate_expression(expr.left)
        right = evaluate_expression(expr.right)
        case expr.operator
        when :MINUS
            return left - right
        when :PLUS
            case expr.left.type
            when :string
                return left + right # concatenate
            when :bool
                return left ^ right # xor
            else # numeric
                return left + right # addition
            end
        when :ASTERISK
            return left * right
        when :STROKE
            return left / right
        when :PERCENT
            return left % right
        when :CARET
            return left ** right

        when :AMPERSAND, :AND
            case expr.left.type
            when :bool
                return left && right # logical and
            else
                return left & right  # bitwise and
            end
        when :PIPE, :OR
            case expr.left.type
            when :bool
                return left || right # logical or
            else
                return left | right  # bitwise or
            end

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

    def visit_GroupLabelExpression(expr)
        return evaluate_expression(expr.expression)
    end

    def visit_FunctionLabelExpression(expr)
        puts "evaluator::visit_FunctionCallConditionExpression"
        p expr
        args = expr.args.map { |a| evaluate_expression(a) }
        return expr.function.call(self, args)
    end

end


class ConditionEvaluator < LabelEvaluator

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

    def visit_LiteralConditionExpression(expr)
        return expr.value
    end

    def visit_VariableConditionExpression(expr)
        if !@variables.has_key?(expr.name)
            raise "unrecognised variable '#{expr.name}'."
        end
        return @variables[expr.name]
    end

    def visit_UnaryOperatorConditionExpression(expr)
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

    def visit_BinaryOperatorConditionExpression(expr)
        left = evaluate_expression(expr.left)
        right = evaluate_expression(expr.right)
        case expr.operator
        when :MINUS
            return left - right
        when :PLUS
            case expr.left.type
            when :int
                return left + right # addition
            when :string
                return left + right # concatentation
            when :bool
                return left ^ right # xor
            end
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

    def visit_GroupConditionExpression(expr)
        return evaluate_expression(expr.expression)
    end

    def visit_FunctionCallConditionExpression(expr)
        puts "evaluator::visit_FunctionCallConditionExpression"
        p expr
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