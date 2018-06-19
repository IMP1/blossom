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
        evaluate_expression(@label.value)
    end

    def evaluate_expression(expr)
        expr.accept(self)
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
        puts "Unary operator:"
        p expr.operator
        case expr.operator
        when :MINUS
            return evaluate_expression(expr.operand)
        end
    end

    def visit_BinaryOperator(expr)
        left = evaluate_expression(expr.left)
        right = evaluate_expression(expr.right)
        case expr.operator
        when :MINUS
            return left - right
        when :PLUS
            return left + right
        end
    end

    def visit_Group(expr)
        return evaluate_expression(expr.expression)
    end



end


# TODO: add condition evaluator
