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

class LiteralConditionExpression < ConditionExpression

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
        puts caller
        raise "Unexpected value type"
    end

    def to_s
        return @value.to_s
    end

end

class VariableConditionExpression < ConditionExpression

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

class UnaryOperatorConditionExpression < ConditionExpression

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

class BinaryOperatorConditionExpression < ConditionExpression

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
        case operator
        when :MINUS
            return @left.type
        when :PLUS
            return @left.type
        when :ASTERISK
            return @left.type
        when :STROKE
            if @left.type == :real || @right.type == :real
                return :real
            else
                return :rational
            end
        when :PERCENT
            return @left.type
        when :CARET
            return @left.type

        when :AMPERSAND, :AND
            return :bool
        when :PIPE, :OR
            return :bool

        when :EQUAL
            return :bool
        when :NOT_EQUAL
            return :bool

        when :LESS
            return :bool
        when :LESS_EQUAL
            return :bool
        when :GREATER
            return :bool
        when :GREATER_EQUAL
            return :bool

        when :BEGINS_WITH
            return :bool
        when :ENDS_WITH
            return :bool
        when :CONTAINS
            return :bool
        end

        puts "Unrecognised binary operator"
        p expr
        raise "Unrecognised binary operator"           
    end

end

class GroupConditionExpression < ConditionExpression

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

class FunctionCallConditionExpression < ConditionExpression

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