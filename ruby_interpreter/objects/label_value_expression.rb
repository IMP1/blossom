require_relative '../visitor'

class LabelValueExpression
    include Visitable

end

class Literal < LabelValueExpression

    attr_reader :value

    def initialize(value)
        @value = value
    end

end

class Variable < LabelValueExpression

    attr_reader :name

    def initialize(name)
        @name = name
    end

end

class Matcher < LabelValueExpression

    attr_reader :keyword

    def initialize(keyword)
        @keyword = keyword
    end

end

class UnaryOperator < LabelValueExpression

    attr_reader :operator
    attr_reader :operand

    def initialize(operator, operand)
        @operator = operator
        @operand = operand
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

end

class Function < LabelValueExpression

    attr_reader :callee
    attr_reader :args

    def initialize(callee, args)
        @callee = callee
        @args = args
    end

end

class Group < LabelValueExpression

    attr_reader :expression

    def initialize(expression)
        @expression = expression
    end

end