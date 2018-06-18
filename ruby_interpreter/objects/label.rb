class Label

    attr_reader :value
    attr_reader :markset

    def initialize(value, type, markset)
        @value = value
        @type = type
        @markset = markset
    end

    def type
        return nil if @value.nil?
        return @value.type
    end

    def to_s
        str = "("
        str += @value.to_s
        return str + ")"
    end

end