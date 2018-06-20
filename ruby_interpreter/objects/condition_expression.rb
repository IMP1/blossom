require_relative 'label_value_expression'

class ConditionExpression
    include Visitable

    def variable?
        raise "Not implemented in this child class (#{self.class.name})."
    end

    def type
        raise "Not implemented in this child class (#{self.class.name})."
    end

end

class Literal < LabelValueExpression

    attr_reader :value

    def initialize(value)
        @value = value
    end

    def variable?
        return false
    end

    def type
        case self.value
        when Integer
            return :int
        when String
            return :string
        when Float
            return :real
        when Rational
            return :rational
        when TrueClass, FalseClass
            return :bool
        end
        puts "Unexpected value type:"
        p self.value.class
        raise "Unexpected value type"
    end

    def to_s
        return @value.to_s
    end

end

class Variable < LabelValueExpression

    attr_reader :name

    def initialize(name, type)
        @name = name
        @type = type
    end

    def variable?
        return true
    end

    def type
        return @type
    end

    def to_s
        return @name
    end

end

class UnaryOperator < LabelValueExpression

    attr_reader :operator
    attr_reader :operand

    def initialize(operator, operand)
        @operator = operator
        @operand = operand
    end

    def variable?
        return @operand.variable?
    end

    def type
        return operand.type
    end

end

class BinaryOperator < LabelValueExpression

    attr_reader :left
    attr_reader :operator
    attr_reader :right

    def initialize(operator, left, right)
        @operator = operator
        @left = left
        @right = right
    end

    def variable?
        return @left.variable? || @right.variable?
    end

    def type
        # TODO: switch on operator and operand types (less than is always bool, for example)
        return left.type
    end

end

class Group < LabelValueExpression

    attr_reader :expression

    def initialize(expression)
        @expression = expression
    end

    def variable?
        return @expression.variable?
    end

    def type
        return expression.type
    end

end

class FunctionCall < ConditionExpression

    attr_reader :function
    attr_reader :arguments

    def initialize(function, arguments)
        @function = function
        @arguments = arguments
    end

    def variable?
        return arguments.any? { |arg| arg.variable? }
    end

    def type
        return @function.return_type
    end

end