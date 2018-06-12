require_relative 'main'
require_relative 'error'
require_relative 'visitor'


class Interpreter < Visitor

    def initialize(host_graph, statements)
        @host_graph = host_graph
        @statements = statements
        @current_graph = host_graph
    end

    def interpret
        begin
            @statements.each { |stmt| execute(stmt) }
        rescue BlossomRuntimeError => e
            Runner.runtime_error(e)
        end
        return @current_graph
    end

    def execute(stmt)
        stmt.accept(self)
    end

    def evaluate(expr)
        expr.accept(self)
    end

    #------------#
    # Statements #
    #------------#

    #-------------#
    # Expressions #
    #-------------#    

end