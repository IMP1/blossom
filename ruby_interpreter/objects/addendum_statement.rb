require_relative 'label_value_expression'

class AddendumStatement
    include Visitable
end

class ProcedureCall < AddendumStatement

    attr_reader :procedure
    attr_reader :arguments

    def initialize(procedure, arguments)
        @procedure = procedure
        @arguments = arguments
    end

end