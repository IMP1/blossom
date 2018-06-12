require_relative 'main'
require_relative 'error'
require_relative 'visitor'

require_relative 'objects/graph'
require_relative 'objects/node'
require_relative 'objects/edge'
require_relative 'objects/label'

class Interpreter < Visitor

    def initialize(host_graph, statements)
        @host_graph = host_graph
        @statements = statements
        @current_graph = evaluate(host_graph)
        @rules = {}
        @procedures = {}
        @variables = {}
    end

    def interpret
        begin
            @statements.each { |stmt| @current_graph = execute(stmt) }
        rescue BlossomRuntimeError => e
            Runner.runtime_error(e)
        end
        return @current_graph
    end

    def execute(stmt, current_graph=nil)
        return stmt.accept(self, current_graph || @current_graph)
    end

    def evaluate(expr)
        return expr.accept(self)
    end

    def valid?(graph)
        return graph != Graph::INVALID
    end

    #------------#
    # Statements #
    #------------#

    def visit_RuleDefinitionStatement(stmt, current_graph)
        # TODO: make a rule class in /objects
        @rules[stmt.name] = {
            parameters:   stmt.parameters,
            match_graph:  evaluate(stmt.match_graph),
            result_graph: evaluate(stmt.result_graph),
            condition:    stmt.condition,
            addendum:     stmt.addendum,
        }
        return current_graph
    end

    def visit_ProcedureDefinitionStatement(stmt, current_graph)
        @procedures[stmt.name] = {
            statements: stmt.statements,
        }
        return current_graph
    end

    def visit_LoopStatement(stmt, current_graph)
        next_graph = execute(stmt.statement, current_graph)
        while valid?(next_graph)
            current_graph = next_graph
            next_graph = execute(stmt.statement, current_graph)
        end
        return current_graph
    end

    def visit_TryStatement(stmt, current_graph)
        next_graph = execute(stmt.statement, current_graph)
        return next_graph if valid?(next_graph)
        return current_graph
    end

    def visit_IfStatement(stmt, current_graph)
        next_graph = execute(stmt.condition, current_graph)
        if valid?(next_graph)
            return execute(stmt.then_stmt)
        elsif !stmt.else_stmt.nil?
            return execute(stmt.else_stmt)
        end
    end

    def visit_WithStatement(stmt, current_graph)
        next_graph = execute(stmt.condition, current_graph)
        if valid?(next_graph)
            return execute(stmt.then_stmt, next_graph)
        elsif !stmt.else_stmt.nil?
            return execute(stmt.else_stmt, current_graph)
        end
    end

    def visit_SequenceStatement(stmt, current_graph)
        stmt.statements.each do |s|
            next_graph = execute(s, current_graph)
            current_graph = next_graph
        end
        return current_graph
    end

    def visit_ChoiceStatement(stmt, current_graph)
        # TODO: will this always choose a /possible/ (valid) rule application if there is one?
        #       If so, what if there is no valid rule application?
        #       At the moment, this just chooses any rule at random.
        i = rand(stmt.statements.size)
        return execute(stmt.statements[i], current_graph)
    end

    def visit_NoopStatement(stmt, current_graph)
        return current_graph
    end

    def visit_InvalidStatement(stmt, current_graph)
        return Graph::INVALID
    end

    def visit_RuleApplicationStatement(stmt, current_graph)
        rule = @rules[stmt.name]
        # TODO: this is where the magic happens
        return Graph::INVALID # TODO: remove
    end

    def visit_ProcedureApplicationStatement(stmt, current_graph)
        procedure = @procedures[stmt.name]
        procedure[:statements].each do |s|
            next_graph = execute(s, current_graph)
            current_graph = next_graph
        end
        return current_graph
    end

    #-------------#
    # Expressions #
    #-------------#    

    def visit_GraphExpression(expr)
        @variables = expr.parameters
        nodes = expr.nodes.map { |n| evaluate(n) }
        edges = expr.edges.map { |n| evaluate(n) }
        @variables = {}
        return Graph.new(nodes, edges, expr.parameters)
    end

    def visit_NodeExpression(expr)
        label = nil # is AnyLabel in match_graphs and EmptyLabel in result_graphs
        if !expr.label.nil?
            label = evaluate(expr.label)
        end
        return Node.new(expr.id, label)
    end

    def visit_EdgeExpression(expr)
        label = nil # is AnyLabel in match_graphs and EmptyLabel in result_graphs
        if !expr.label.nil?
            label = evaluate(expr.label)
        end
        return Edge.new(expr.source_id, expr.target_id, label)
    end

    def visit_LabelExpression(expr)
        value = evaluate(expr.value)
        markset = expr.markset.map {|m| evaluate(m) }
        return Label.new(value, markset)
    end

    def visit_EmptyLabelExpression(expr)
        return Label.new(:void, [])
    end

    def visit_VoidLabelValueExpression(expr)
        return :void
    end

    def visit_AnyLabelValueExpression(expr)
        return :any
    end

    def visit_LiteralExpression(expr)

    end

    def visit_VariableExpression(expr)
        p @variables
    end

    def visit_MarkExpression(expr)

    end

    def visit_BinaryOperatorExpression(expr)

    end

    def visit_FunctionCallExpression(expr)

    end


end