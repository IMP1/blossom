class Node

    attr_reader :id
    attr_accessor :label

    def initialize(id, label)
        @id = id
        @label = label
    end

    def to_s
        str = @id.to_s + " " + @label.to_s
        return str
    end

end