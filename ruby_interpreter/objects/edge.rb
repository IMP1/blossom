class Edge

    attr_reader :source_id
    attr_reader :target_id
    attr_reader :label

    def initialize(source_id, target_id, label)
        @source_id = source_id
        @target_id = target_id
        @label = label
    end

    def to_s
        return @source_id.to_s + "->" + @target_id.to_s + " " + @label.to_s
    end

    def clone
        return Edge.new(@source_id, @target_id, @label&.clone)
    end

end