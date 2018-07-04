require_relative '../visitor'

class LabelValueExpression
    include Visitable

    def variable?
        raise "Not implemented in this child class (#{self.class.name})."
    end

    def type
        raise "Not implemented in this child class (#{self.class.name})."
    end

end

class LiteralLabelExpression < LabelValueExpression

    TYPES = [:int, :string, :real, :rational, :bool]

    attr_reader :value

    def initialize(value)
        @value = value
    end

    def variable?
        return false
    end

    def type
        return nil if self.value.nil?
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
        puts "Unrecognised type:"
        p self
        p self.class
        puts caller
        raise "Unrecognised type"
    end

    def to_s
        return @value.to_s
    end

end

class VariableLabelExpression < LabelValueExpression

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

class MatcherLabelExpression < LabelValueExpression

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

class UnaryOperatorLabelExpression < LabelValueExpression

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

    def to_s
        op = case @operator
        when :MINUS
            "-"
        when :NOT
            "!"
        end
        return op + @operand.to_s
    end

end

class BinaryOperatorLabelExpression < LabelValueExpression

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

    def to_s
        op = case @operator
        when :MINUS
            "-"
        when :PLUS
            "+"
        when :ASTERISK
            "*"
        when :STROKE
            "/"
        when :PERCENT
            "%"
        when :CARET
            "^"
        when :AMPERSAND, :AND
            "&"
        when :PIPE, :OR
            "|"

        when :EQUAL
            "="
        when :NOT_EQUAL
            "!="

        when :LESS
            "<"
        when :LESS_EQUAL
            "<="
        when :GREATER
            ">"
        when :GREATER_EQUAL
            ">="

        when :BEGINS_WITH
            "^="
        when :ENDS_WITH
            "$="
        when :CONTAINS
            "~="

        end
        return @left.to_s + " #{op} " + @right.to_s
    end

end

class GroupLabelExpression < LabelValueExpression

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

    def to_s
        return "(#{@expression.to_s})"
    end

end