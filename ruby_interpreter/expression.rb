require_relative 'visitor'

class Expression
    include Visitable

    attr_reader :token

    def initialize(token)
        @token = token
    end

end

class GraphExpression < Expression

    attr_reader :nodes
    attr_reader :edges
    attr_reader :parameters

    def initialize(token, nodes, edges, parameters)
        super(token)
        @nodes = nodes
        @edges = edges
        @parameters = parameters
    end

end

class NodeExpression < Expression

    attr_reader :id
    attr_reader :label

    def initialize(token, label)
        super(token)
        @id = token.literal
        @label = label
    end

end

class EdgeExpression < Expression

    attr_reader :source_id
    attr_reader :target_id
    attr_reader :label

    def initialize(token, source_id, target_id, label)
        super(token)
        @source_id = source_id
        @target_id = target_id
        @label = label
    end

end

class LabelExpression < Expression

    attr_reader :value
    attr_reader :markset

    def initialize(token, value, markset)
        super(token)
        @value = value
        @markset = markset
    end

end

class EmptyLabelExpression < LabelExpression

    def initialize(token)
        super(token, nil, [])
    end

end

class VoidLabelValueExpression < Expression

    def initialize(token)
        super(token)
    end

end

class AnyLabelValueExpression < Expression

    def initialize(token)
        super(token)
    end

end

class LiteralExpression < Expression

    attr_reader :value
    attr_reader :type

    def initialize(token, value, type)
        super(token)
        @value = value
        @type = type
    end

end

class VariableExpression < Expression

    attr_reader :name
    attr_reader :type

    def initialize(token, name, type=nil)
        super(token)
        @name = name
        @type = type
    end

end

class MarkExpression < Expression

    attr_reader :value

    def initialize(token, value)
        super(token)
        @value = value
    end

end

class UnaryOperatorExpression < Expression

    attr_reader :operand
    attr_reader :operator

    def initialize(operator, operand)
        super(operator)
        @operand = operand
        @operator = operator
    end

end

class BinaryOperatorExpression < Expression

    attr_reader :left
    attr_reader :right
    attr_reader :operator

    def initialize(left, operator, right)
        super(operator)
        @left = left
        @right = right
        @operator = operator
    end

end

class FunctionCallExpression < Expression

    attr_reader :args

    def initialize(callee, args)
        super(callee.token)
        @args = args
    end

end

class GroupingExpression < Expression

    attr_reader :expression

    def initialize(token, expr)
        super(token)
        @expression = expr
    end

end
