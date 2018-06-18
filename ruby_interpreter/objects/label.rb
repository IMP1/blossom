class Label

    attr_reader :value
    attr_reader :markset

    def self.empty
        return Label.new(nil, nil, [])
    end

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
        str = @value.to_s
        if !@markset.nil? && !@markset.empty?
            str += " " if !str.empty?
            str += @markset.join(", ")
        end
        return "(" + str + ")"
    end

end