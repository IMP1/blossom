require_relative '../visitor'

class ConditionExpression
    include Visitable

    def variable?
        raise "Not implemented in this child class (#{self.class.name})."
    end

    def type
        raise "Not implemented in this child class (#{self.class.name})."
    end

end

class Literal < ConditionExpression

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
        # TODO: add others
        end
    end

    def to_s
        return @value.to_s
    end

end

class Variable < ConditionExpression

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

class Matcher < ConditionExpression

    attr_reader :keyword

    def initialize(keyword)
        @keyword = keyword
    end

    def variable?
        return false
    end

    def type
        return nil
    end

    def to_s
        return @keyword.to_s
    end

end

class UnaryOperator < ConditionExpression

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

class BinaryOperator < ConditionExpression

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
        return left.type
    end

end

class Group < ConditionExpression

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

    # TODO: add function call

end