class Edge

    attr_reader :source_id
    attr_reader :target_id
    attr_reader :label

    def initialize(source, target, label)
        @source_id = source
        @target_id = target
        @label = label
    end

    def to_s
        return @source_id.to_s + "->" + @target_id.to_s + " " + @label.to_s
    end

end