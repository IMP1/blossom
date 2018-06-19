require_relative 'main'
require_relative 'error'
require_relative 'visitor'

require_relative 'objects/graph'
require_relative 'objects/node'
require_relative 'objects/edge'
require_relative 'objects/label'
require_relative 'objects/label_value_expression'
# require_relative 'objects/rule_condition_expression'
require_relative 'objects/rule'
require_relative 'objects/rule_application'

class Interpreter < Visitor

    def initialize(host_graph, statements)
        @log = Log.new("Interpreter")
        @log.set_level(Log::ALL) if $verbose
        @host_graph = host_graph
        @statements = statements
        @current_graph = evaluate(host_graph)
        @rules = {}
        @procedures = {}
        @variables = {}
    end

    def interpret
        @log.trace("Host Graph:")
        @log.trace(@current_graph.to_s)
        begin
            @statements.each do |stmt| 
                @log.trace("Executing statement:")
                @log.trace(stmt.to_s)
                @current_graph = execute(stmt) 
            end
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
        @log.trace("Defining rule #{stmt.name}.")
        match_graph = evaluate(stmt.match_graph)
        result_graph = evaluate(stmt.result_graph)
        condition = evaluate(stmt.condition) if !stmt.condition.nil?
        addendum = evaluate(stmt.addendum) if !stmt.addendum.nil?
        @rules[stmt.name] = Rule.new(stmt.name, stmt.parameters, match_graph, result_graph, condition, addendum)
        return current_graph
    end

    def visit_ProcedureDefinitionStatement(stmt, current_graph)
        @log.trace("Defining proc #{stmt.name}.")
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
        else
            return current_graph
        end
    end

    def visit_WithStatement(stmt, current_graph)
        next_graph = execute(stmt.condition, current_graph)
        if valid?(next_graph)
            return execute(stmt.then_stmt, next_graph)
        elsif !stmt.else_stmt.nil?
            return execute(stmt.else_stmt, current_graph)
        else
            return current_graph
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
        @log.trace("Choosing from #{stmt.statements.size}.")
        i = rand(stmt.statements.size)
        @log.trace("Chose #{i}.")
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
        application = RuleApplication.new(rule, current_graph)
        next_graph = application.attempt
        return next_graph
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
        type = value.type
        markset = expr.markset&.map {|m| evaluate(m) }
        return Label.new(value, type, markset)
    end

    #-------------------------#
    # Label Value Expressions #
    #-------------------------#

    def visit_EmptyLabelExpression(expr)
        return Label.new(Matcher.new(:empty), nil, [])
    end

    def visit_VoidLabelValueExpression(expr)
        return Matcher.new(:void)
    end

    def visit_AnyLabelValueExpression(expr)
        return Matcher.new(:any)
    end

    def visit_LiteralExpression(expr)
        return Literal.new(expr.value)
    end

    def visit_VariableExpression(expr)
        type = @variables[expr.name][:type_name].to_sym
        return Variable.new(expr.name, type)
    end

    def visit_MarkExpression(expr)
        return expr.value
    end

    def visit_GroupingExpression(expr)
        return evaluate(expr.expression)
    end

    def visit_BinaryOperatorExpression(expr)
        left = evaluate(expr.left)
        right = evaluate(expr.right)
        return BinaryOperator.new(expr.operator.name, left, right)
    end

    def visit_FunctionCallExpression(expr)
        puts "Interpreter::visit_FunctionCallExpression"
        p expr
        return expr
    end

end