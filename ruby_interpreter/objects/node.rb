class Node

    attr_reader :id
    attr_accessor :label

    def initialize(id, label)
        @id = id
        @label = label
    end

    def to_s
        str = @id.to_s
        str += " " + @label.to_s if !@label.nil?
        return str
    end

    def clone
        return Node.new(@id, @label&.clone)
    end

end