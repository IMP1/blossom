class Expression

    attr_reader :token

    def initialize(token)
        @token = token
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
    # attr_reader :type

    def initialize(token, value) #, type)
        super(token)
        @value = value
        # @type = type
    end

end

class VariableExpression < Expression

    attr_reader :name
    attr_reader :type

    def initialize(token, name, type)
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