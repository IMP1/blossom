class Procedure

    attr_reader :name
    attr_reader :parameter_types

    def initialize(name, parameter_types, &block)
        @name = name
        @parameter_types = parameter_types
        @block = block
    end

    def call(evaluator, args)
        @block.call(evaluator, args)
    end

    def self.print
        return Procedure.new("node", [:int]) do |evaluator, args|
            puts args[0]
        end
    end

end