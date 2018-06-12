class Edge

    attr_reader :source_id
    attr_reader :target_id
    attr_reader :label

    def initialize(source, target, label)
        @source_id = source
        @target_id = target
        @label = label
    end

end