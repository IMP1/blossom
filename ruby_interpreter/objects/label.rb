class Label

    attr_reader :value
    attr_reader :type
    attr_reader :markset

    def initialize(value, type, markset)
        @value = value
        @type = type
        @markset = markset
    end

end