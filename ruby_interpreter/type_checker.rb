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

class TypeChecker < Visitor

    def initialize(instructions)
        @log = Log.new("TypeChecker")
        @log.set_level(Log::ALL) if $verbose
        @instructions = instructions
        @variables = nil
        @matching = false
        @applying = false
    end

    def type_check(type, *types)
        return types.include?(type)
    end

    def error(expr, message)
        e = BlossomTypeError.new(expr.token, message)
        Runner.compile_error(e)
        return e
    end

    #--------------------------------------------------------------------------#
    #                         Publicly-Used Functions                          #
    #--------------------------------------------------------------------------#

    def check_programme
        @instructions.select {|inst| inst.is_a?(RuleDefinitionStatement) }.each do |rule| 
            check_rule(rule)
        end
    end

    def check_graph(graph)
        graph.nodes.group_by { |n| n.id }.select { |id, nodes| nodes.size > 1 }.each do |id, nodes|
            error(graph, "There were #{nodes.size} nodes with the ID #{id}. IDs must be unique within a graph.")
        end
        graph.nodes.each { |n| check_expression(n) }
        graph.edges.each { |n| check_expression(n) }
    end

    #--------------------------------------------------------------------------#
    #                             Blossom Objects                              #
    #--------------------------------------------------------------------------#

    def check_rule(rule)
        @log.trace("Type checking rule #{rule.name}.")

        @variables = rule.parameters || {}

        check_match_graph(rule.match_graph)
        check_result_graph(rule.result_graph)

        check_expression(rule.condition) if !rule.condition.nil?
        check_statement(rule.addendum) if !rule.addendum.nil?

        @variables = nil
    end

    def check_match_graph(graph)
        @matching = true
        check_graph(graph)
        @matching = false
    end

    def check_result_graph(graph)
        @applying = true
        check_graph(graph)
        @applying = false
    end

    def check_expression(expr)
        expr.accept(self)
    end

    def check_statement(stmt)
        stmt.accept(self)
    end

    #-------------#
    # Expressions #
    #-------------#

    def visit_NodeExpression(expr)
        if !expr.label.nil?
            check_expression(expr.label)
        end
    end

    def visit_EdgeExpression(expr)
        label = nil # is AnyLabel in match_graphs and EmptyLabel in result_graphs
        if !expr.label.nil?
            label = check_expression(expr.label)
        end
    end

    def visit_LabelExpression(expr)
        check_expression(expr.value) if !expr.value.nil?
        markset = expr.markset&.map {|m| check_expression(m) }
    end

    #-------------------------#
    # Label Value Expressions #
    #-------------------------#

    def visit_EmptyLabelExpression(expr)
    end

    def visit_VoidLabelValueExpression(expr)
    end

    def visit_MaintainLabelValueExpression(expr)
    end

    def visit_AnyLabelValueExpression(expr)
    end

    def visit_LiteralExpression(expr)
        return expr.type
    end

    def visit_VariableExpression(expr)
        @log.trace("Type checking variable.")
        expected = @variables[expr.name][:type_name]
        actual = expr.type
        if !type_check(actual, expected)
            error(expr, "Variable '#{expr.name}' has the wrong type. It should be a '#{expected}', but it is a '#{actual}'.")
        end
        return expr.type
    end

    def visit_MarkExpression(expr)
        # if !(@matching || @applying)
            # error(expr, "Cannot have marks in a normal graph")
        # end
        if !(@matching || @applying) && expr.value[0] == '¬'
            error(expr, "Cannot have negative marks in a normal graph")
        end
    end

    def visit_GroupingExpression(expr)
        @log.trace("Type checking grouped expression.")
        check_expression(expr.expression)
    end

    def visit_UnaryOperatorExpression(expr)
        @log.trace("Type checking unary operation.")
        operand = check_expression(expr.operand)
        case expr.operator.name

        when :MINUS
            if !type_check(operand, :int, :real, :rational)
                error(expr, "Cannot inverse non-numeric values.")
            end
            return operand

        when :NOT, :EXCLAMATION
            if !type_check(operand, :bool)
                error(expr, "Cannot invsere non-boolean values.")
            end
            return :bool

        end
        puts "Unrecognised unary operator"
        p expr
        raise "Unrecognised unary operator"
    end

    def visit_BinaryOperatorExpression(expr)
        @log.trace("Type checking binary operation.")
        left = check_expression(expr.left)
        right = check_expression(expr.right)
        case expr.operator.name

        when :MINUS
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot subtract non-numeric values.")
            end
            if type_check(left, :real) || type_check(right, :real)
                return :real
            end
            if type_check(left, :rational) || type_check(right, :rational)
                return :rational
            end
            return :int

        when :PLUS
            if type_check(left, :string) && type_check(right, :string)
                return :string
            end
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot add the types '#{left}' and '#{right}'.")
            end
            if type_check(left, :real) || type_check(right, :real)
                return :real
            end
            if type_check(left, :rational) || type_check(right, :rational)
                return :rational
            end
            return :int

        when :ASTERISK
            if type_check(left, :string) && type_check(right, :int)
                return :string
            end
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot add the types '#{left}' and '#{right}'.")
            end
            if type_check(left, :real) || type_check(right, :real)
                return :real
            end
            if type_check(left, :rational) || type_check(right, :rational)
                return :rational
            end
            return :int
            
        when :STROKE
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot divide non-numeric values.")
            end
            if type_check(left, :real) || type_check(right, :real)
                return :real
            end
            return :rational

        when :PERCENT
            if !type_check(left, :int) || !type_check(right, :int)
                error(expr, "Cannot modulo non-integer numbers.")
            end
            return :int

        when :CARET
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot raise '#{left}' type to '#{right}' type.")
            end
            if type_check(left, :real) || type_check(right, :real)
                return :real
            end
            if type_check(left, :rational) || type_check(right, :rational)
                return :rational
            end
            return :int

        when :AMPERSAND, :AND
            if !type_check(left, :bool) || !type_check(right, :bool)
                error(expr, "'#{left}' and '#{right}' types can not both be evaluated as a boolean.")
            end
            return :bool
        when :PIPE, :OR
            if !type_check(left, :bool) || !type_check(right, :bool)
                error(expr, "'#{left}' and '#{right}' types can not both be evaluated as a boolean.")
            end
            return :bool

        when :EQUAL
            return :bool
        when :NOT_EQUAL
            return :bool

        when :LESS
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot compare non-numeric values.")
            end
            return :bool
        when :LESS_EQUAL
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot compare non-numeric values.")
            end
            return :bool
        when :GREATER
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot compare non-numeric values.")
            end
            return :bool
        when :GREATER_EQUAL
            if !type_check(left, :int, :real, :rational) || !type_check(right, :int, :real, :rational)
                error(expr, "Cannot compare non-numeric values.")
            end
            return :bool

        when :BEGINS_WITH
            if !type_check(left, :string) || !type_check(right, :string)
                error(expr, "Cannot compare non-string values.")
            end
            return :bool
        when :ENDS_WITH
            if !type_check(left, :string) || !type_check(right, :string)
                error(expr, "Cannot compare non-string values.")
            end
            return :bool
        when :CONTAINS
            if !type_check(left, :string) || !type_check(right, :string)
                error(expr, "Cannot compare non-string values.")
            end
            return :bool

        end
        puts "Unrecognised binary operator"
        p expr
        raise "Unrecognised binary operator"
    end

    def visit_FunctionCallExpression(expr)
        puts "TypeChecker::visit_FunctionCallExpression"
        p expr
        return expr
    end

end