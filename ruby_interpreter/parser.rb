require_relative 'log'
require_relative 'expression'
require_relative 'statement'
require_relative 'main'
require_relative 'error'

class Parser

    def initialize(tokens)
        @log = Log.new("Parser")
        @tokens = tokens
        @current = 0
    end

    #--------------------------------------------------------------------------#
    #                             Helper Functions                             #
    #--------------------------------------------------------------------------#

    def eof?
        return peek.name == :EOF
    end

    def peek
        return @tokens[@current]
    end

    def previous
        return @tokens[@current - 1]
    end

    def advance
        @current += 1 if !eof?
        return previous
    end

    def check(type)
        return false if eof?
        return peek.name == type
    end

    def match_token(*types)
        types.each do |t|
            if check(t)
                advance
                return true
            end
        end
        return false
    end

    def consume_token(type, error_message)
        return advance if check(type)
        raise fault(peek, error_message)
    end

    def fault(token, message)
        e = BlossomParseError.new(token, message)
        Compiler.compile_error(e)
        return e
    end

    def escape_string(str)
        escaped = str
        escaped = escaped.gsub('\\n', "\n")
        escaped = escaped.gsub('\\t', "\t")
        escaped = escaped.gsub('\\"', "\"")
        return escaped
    end

    #--------------------------------------------------------------------------#
    #                         Publicly-Used Functions                          #
    #--------------------------------------------------------------------------#

    def parse_programme
        statements = []
        while !eof?
            stmt = declaration
            statements.push(stmt) if !stmt.nil?
        end
        return statements
    end

    def parse_graph(parameters=nil)
        parameters ||= []
        consume_token(:LEFT_SQUARE, "Expecting '[' to start a graph.")
        nodes = []
        edges = []
        while !eof? && !check(:PIPE) && !check(:RIGHT_SQUARE)
            nodes.push(parse_node(parameters))
        end
        if match_token(:PIPE)
            while !eof? && !check(:RIGHT_SQUARE)
                edges.push(*parse_edge(parameters))
            end
        end
        consume_token(:RIGHT_SQUARE, "Expecting '[' to end a graph.")
    end

    #--------------------------------------------------------------------------#
    #                            Grammar Functions                             #
    #--------------------------------------------------------------------------#

    #------------------------------------#
    # Blossom Graph Grammar Nonterminals #
    #------------------------------------#
    def parse_node(parameters)
        node_id_token = consume_token(:INTEGER_LITERAL)
        if match_token(:LEFT_PAREN)
            node_label = parse_label(parameters)
            consume_token(:RIGHT_PAREN)
        end
        return NodeExpression.new(node_id_token, node_label)
        # TODO: define this expression.
    end

    def parse_label(parameters)
        value = parse_label_value(parameters)
        if value.nil? || match_token(:COMMA)
            markset = parse_markset
        end
        return LabelExpression.new(value, markset)
        # TODO: define this expression.
    end

    def parse_label_value(parameters)
        if match_token(:ASTERISK)
            return AnyLabelValueExpression.new(previous)
            # TODO: define this expression.
        end
        if match_token(:BOOLEAN_LITERAL, :INTEGER_LITERAL, :RATIONAL_LITERAL, :REAL_LITERAL, :STRING_LITERAL)
            token = previous
            value = previous.literal
            return LiteralExpression.new(token, value)
            # TODO: define this expression.
        elsif match_token(:VOID)
            token = previous
            return VoidLabelExpression.new(token)
            # TODO: define this expression.
        elsif match_token(:IDENTIFIER)
            token = previous
            var_name = previous.lexeme
            if parameters.has_key?(var_name)
                type = parameters[var_name]
                return VariableExpression.new(token, var_name, type)
                # TODO: define this expression.
            else
                fault(token, "Unrecognised value for a label.")
            end
        end
    end

    def parse_markset
        set = []
        while match_token(:MARK)
            token = previous
            value = previous.literal
            set.push(Mark.new(token, value))
            # TODO: define this expression.
        end
        return set
    end

    def parse_edge(parameters)
        source_id = consume_token(:INTEGER_LITERAL)
        both_ways = false
        if match_token(:BIDIRECTIONAL)
            arrow_token = previous
            both_ways = true
        else
            arrow_token = consume_token(:UNIDIRECTIONAL, "Expecting an arrow (-> or <->) between the nodes' ids.")
        end
        target_id = consume_token(:INTEGER_LITERAL)
        if match_token(:LEFT_PAREN)
            edge_label = parse_label(parameters)
            consume_token(:RIGHT_PAREN)
        end
        if both_ways
            return EdgeExpression.new(source_id, target_id, edge_label), 
                   EdgeExpression.new(target_id, source_id, edge_label)
        else
            return EdgeExpression.new(source_id, target_id, edge_label)
            # TODO: define this expression.
        end
    end


    #----------------------------------------#
    # Blossom Programme Grammar Nonterminals #
    #----------------------------------------#
    def declaration
        if match_token(:RULE_DEF)
            return rule_definition
        end
        if match_token(:PROC_DEF)
            return procedure_definition
        end
        return rule_application
    end

    def rule_definition
        rule_keyword_token = previous
        rule_name_token = consume_token(:IDENTIFIER, "Expecting a name for the rule.")
        parameters = []
        if match_token(:LESS)
            parameters = parameter_list
            consume_token(:GREATER, "Expecting '>' after the rule's parameters.")
        end
        host_graph = parse_graph(parameters)
        consume_token(:RIGHT_ARROW)
        result_graph = parse_graph(parameters)
        condition = nil
        if match_token(:WHERE)
            where_keyword_token = previous
            where_condition = expression
        end
        addendum = nil
        if match_token(:ALSO)
            addendun_keyword_token = previous
            addendum_statement = statement
        end
        return RuleDefinitionStatement.new(rule_name_token, parameters, host_graph, result_graph, condition, addendum)
        # TODO: define this statement.
    end

    def parameter_list
        
    end

    def procedure_definition

    end

    def rule_application

    end

    def statement
        
    end


    # Remnants from Raven. Pick and choose what is still relavent to blossom.

    def expression
        return or_shortcircuit
    end

    def or_shortcircuit
        expr = and_shortcircuit

        while match_token(:DOUBLE_PIPE)
            op = previous
            right = and_shortcircuit
            expr = ShortCircuitExpression.new(expr, op, right)
        end

        return expr
    end

    def and_shortcircuit
        expr = equality

        while match_token(:DOUBLE_AMPERSAND)
            op = previous
            right = equality
            expr = ShortCircuitExpression.new(expr, op, right)
        end

        return expr
    end

    def equality
        expr = comparison
        while match_token(:EQUAL, :NOT_EQUAL)
            op = previous
            right = comparison
            expr = BinaryExpression.new(expr, op, right)
        end
        return expr
    end

    def comparison
        expr = addition
        while match_token(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL, :BEGINS_WITH, :ENDS_WITH, :CONTAINS)
            operator = previous
            right = addition
            expr = BinaryExpression.new(expr, operator, right)
        end
        return expr
    end

    def addition
        expr = multiplication
        while match_token(:MINUS, :PLUS, :PIPE, :PERCENT)
            operator = previous
            right = multiplication
            expr = BinaryExpression.new(expr, operator, right)
        end
        return expr
    end

    def multiplication
        expr = exponent
        while match_token(:STROKE, :ASTERISK, :AMPERSAND, :DOUBLE_STROKE)
            operator = previous
            right = exponent
            expr = BinaryExpression.new(expr, operator, right)
        end
        return expr
    end

    def exponent
        expr = unary
        while match_token(:CARET)
            operator = previous
            right = unary
            expr = BinaryExpression.new(expr, operator, right)
        end
        return expr
    end

    def unary
        if match_token(:NOT, :MINUS, :EXCLAMATION)
            operator = previous
            right = unary
            return UnaryExpression.new(operator, right)
        end
        return call
    end

    def call
        expr = primary

        loop do
            if match_token(:LEFT_PAREN)
                expr = finish_call(expr)
            elsif match_token(:LEFT_SQUARE)
                key = or_shortcircuit
                expr = index_of(expr, key)
            elsif match_token(:DOT)
                field = consume_token(:IDENTIFIER, "Expecting property name after '.'.")
                expr = PropertyExpression.new(expr, field)
            else
                break
            end
        end

        return expr
    end

    def finish_call(callee)
        args = []
        if !check(:RIGHT_PAREN)
            loop do
                args.push(expression)
                break if !match_token(:COMMA)
            end
        end
        paren = consume_token(:RIGHT_PAREN, "Expecting ')' after arguments.")
        return CallExpression.new(callee, paren, args)
    end

    def index_of(expr, key)
        paren = consume_token(:RIGHT_SQUARE, "Expecting ']' after index.")
        return IndexExpression.new(previous, expr, key)
    end

    def primary
        if match_token(:STRING_LITERAL)
            return primitive_literal(try_coerce_type([:string], @type_hint), previous.literal, previous)
        end
        if match_token(:BOOLEAN_LITERAL)
            return primitive_literal(try_coerce_type([:bool], @type_hint), previous.literal, previous)
        end        
        if match_token(:INTEGER_LITERAL)
            return primitive_literal(try_coerce_type([:int], @type_hint), previous.literal, previous)
        end
        if match_token(:REAL_LITERAL)
            return primitive_literal(try_coerce_type([:real], @type_hint), previous.literal, previous)
        end
        if match_token(:RATIONAL_LITERAL)
            return primitive_literal(try_coerce_type([:rational], @type_hint), previous.literal, previous)
        end
        if match_token(:NULL_LITERAL)
            # TODO: should NULL have its own type? Or is it a special value for the optional type?
            # Should this at least be attempted to coerce?
            return primitive_literal([:optional, nil], previous.literal, previous)
        end

        # Array Literals
        if match_token(:LEFT_SQUARE)
            array = []
            while !eof? && !check(:RIGHT_SQUARE)
                array.push(expression)
                break if !match_token(:COMMA)
            end
            consume_token(:RIGHT_SQUARE, "Expecting ']' after array literal.")
            var_type = [:array, nil]
            if !array.empty?
                var_type = [:array, array.first.type]
            end
            return ArrayExpression.new(previous, array, try_coerce_type(var_type, @type_hint))
        end

        # Type Literals / Function Literals
        if check(:TYPE_LITERAL)
            var_token = peek.literal
            type_value = variable_type
            if match_token(:LEFT_BRACE)
                return subroutine_body(previous, [], type_value)
            else
                if type_value == [:func]
                    # Add nil values for func inferrence later
                    type_value += [[nil, nil]]
                end
                return LiteralExpression.new(var_token, type_value, [:type])
            end
        end

        # Function Literals
        if match_token(:LEFT_PAREN)
            if check(:TYPE_LITERAL) || match_user_type?
                type = variable_type
                if check(:IDENTIFIER)
                    params = []
                    var_name = consume_token(:IDENTIFIER, "Expecting parameter name.")
                    params.push({name: var_name, type: type})
                    while !check(:RIGHT_PAREN) && !eof?
                        break if !check(:COMMA)
                        consume_token(:COMMA, "Expecting ',' in parameter list.")
                        type = variable_type
                        var_name = consume_token(:IDENTIFIER, "Expecting parameter name.")
                        params.push({name: var_name, type: type})
                    end
                    consume_token(:RIGHT_PAREN, "Expecting ')' after parameter list.")
                    return_type = []
                    if check(:TYPE_LITERAL) || (check(:IDENTIFIER) && match_user_type?)
                        return_type = variable_type
                    end
                    func_token = consume_token(:LEFT_BRACE, "Expecting '{' before function body.")
                    body = block
                    return FunctionExpression.new(func_token, params, return_type, body)
                else
                    revert
                    group_token = previous
                    expr = expression
                    consume_token(:RIGHT_PAREN, "Expecting ')' after expression.")
                    return GroupingExpression.new(group_token, expr)
                end
            end
            group_token = previous
            expr = expression
            consume_token(:RIGHT_PAREN, "Expecting ')' after expression.")
            return GroupingExpression.new(group_token, expr)
        end

        if match_token(:LEFT_BRACE)
            return subroutine_body(previous, [], [])
        end

        if match_token(:IDENTIFIER)
            if user_type?(previous.lexeme)
                token = previous
                type = user_type(previous.lexeme)
                case type[0]
                when :struct
                    initialiser = {}
                    if match_token(:LEFT_BRACE)
                        while !eof? && !check(:RIGHT_BRACE)
                            # TODO: Get default values for fields
                            field = assignment
                            initialiser[field.name.lexeme] = field.expression
                        end
                        consume_token(:RIGHT_BRACE, "Expecting '}' after struct initialiser.")
                        @log.trace("New Struct Initialiser" + type.inspect)
                        return StructExpression.new(token, type, initialiser)
                    else
                        return LiteralExpression.new(token, type, [:type])
                    end
                end
            end
            return VariableExpression.new(previous)
        end

        raise fault(peek, "Expecting an expression. Got '#{peek.lexeme}'.")
    end

    def primitive_literal(type, value, token)
        case type
        when [:string]
            return LiteralExpression.new(token, escape_string(value.to_s), type)
        when [:int]
            return LiteralExpression.new(token, value.to_i, type)
        when [:real]
            return LiteralExpression.new(token, value.to_f, type)
        when [:rational]
            return LiteralExpression.new(token, value.to_r, type)
        when [:bool]
            return LiteralExpression.new(token, !!value, type)
        else
            if type[0] == :optional
                return LiteralExpression.new(token, value, type)
            else
                raise "What kind of literal is this?"
            end
        end
    end

    def subroutine_body(token, params, return_type)
        body = block
        return FunctionExpression.new(token, params, return_type, body)
    end

end
