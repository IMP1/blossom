class Label

    attr_reader :value
    attr_reader :markset

    def initialize(value, markset)
        @value = value
        @markset = markset
    end

end