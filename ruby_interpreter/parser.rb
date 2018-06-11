require_relative 'log'
require_relative 'main'
require_relative 'error'

require_relative 'expression'
# require_relative 'statement'

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
        Runner.compile_error(e)
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
            break if !match_token(:COMMA)
        end
        if match_token(:PIPE)
            while !eof? && !check(:RIGHT_SQUARE)
                edges.push(*parse_edge(parameters))
                break if !match_token(:COMMA)
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
        node_id_token = consume_token(:INTEGER_LITERAL, "Expecting an id for the node.")
        if match_token(:LEFT_PAREN)
            node_label = parse_label(parameters)
            consume_token(:RIGHT_PAREN, "Expecting ')' after a node's label.")
        end
        return NodeExpression.new(node_id_token, node_label)
    end

    def parse_label(parameters)
        paren_token = previous
        value = parse_label_value(parameters)
        if value.nil? || match_token(:COMMA)
            markset = parse_markset
        end
        return LabelExpression.new(paren_token, value, markset)
    end

    def parse_label_value(parameters)
        if match_token(:ASTERISK)
            return AnyLabelValueExpression.new(previous)
        end
        if match_token(:BOOLEAN_LITERAL, :INTEGER_LITERAL, :RATIONAL_LITERAL, :REAL_LITERAL, :STRING_LITERAL)
            token = previous
            value = previous.literal
            return LiteralExpression.new(token, value)
        elsif match_token(:VOID)
            token = previous
            return VoidLabelValueExpression.new(token)
        elsif match_token(:IDENTIFIER)
            token = previous
            var_name = previous.lexeme
            if parameters.has_key?(var_name)
                type = parameters[var_name][:type_name]
                return VariableExpression.new(token, var_name, type)
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
            set.push(MarkExpression.new(token, value))
        end
        return set
    end

    def parse_edge(parameters)
        source_id = consume_token(:INTEGER_LITERAL, "Expecting an id of a source node.")
        both_ways = false
        if match_token(:BIDIRECTIONAL)
            arrow_token = previous
            both_ways = true
        else
            arrow_token = consume_token(:UNIDIRECTIONAL, "Expecting an arrow (-> or <->) between the nodes' ids.")
        end
        target_id = consume_token(:INTEGER_LITERAL, "Expecting an id of a target node.")
        if match_token(:LEFT_PAREN)
            edge_label = parse_label(parameters)
            consume_token(:RIGHT_PAREN, "Expecting ')' after an edge's label.")
        end
        if both_ways
            return EdgeExpression.new(arrow_token, source_id, target_id, edge_label), 
                   EdgeExpression.new(arrow_token, target_id, source_id, edge_label)
        else
            return EdgeExpression.new(arrow_token, source_id, target_id, edge_label)
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
        match_graph = parse_graph(parameters)
        consume_token(:RIGHT_ARROW, "Expecting => between the match graph and the result graph.")
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
        return RuleDefinitionStatement.new(rule_name_token, parameters, match_graph, result_graph, condition, addendum)
    end

    def parameter_list
        params = {}
        while !eof? && !check(:GREATER)
            param_type_token = consume_token(:IDENTIFIER, "Expecting a type for the parameters.")
            param_type_name = param_type_token.lexeme
            while !eof? && !check(:SEMICOLON)
                param_name_token = consume_token(:IDENTIFIER, "Expecting a name for this parameter.")
                param_name = param_name_token.lexeme
                params[param_name] = { name: param_name, token: param_name_token, type_name: param_type_name, type_token: param_type_token }
                break if !match_token(:COMMA)
            end
        end
        return params
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

        while match_token(:PIPE)
            op = previous
            right = and_shortcircuit
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end

        return expr
    end

    def and_shortcircuit
        expr = equality

        while match_token(:AMPERSAND)
            op = previous
            right = equality
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end

        return expr
    end

    def equality
        expr = comparison
        while match_token(:EQUAL, :NOT_EQUAL)
            operator = previous
            right = comparison
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end
        return expr
    end

    def comparison
        expr = addition
        while match_token(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL, :BEGINS_WITH, :ENDS_WITH, :CONTAINS)
            operator = previous
            right = addition
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end
        return expr
    end

    def addition
        expr = multiplication
        while match_token(:MINUS, :PLUS, :PIPE, :PERCENT)
            operator = previous
            right = multiplication
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end
        return expr
    end

    def multiplication
        expr = exponent
        while match_token(:STROKE, :ASTERISK, :AMPERSAND, :DOUBLE_STROKE)
            operator = previous
            right = exponent
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end
        return expr
    end

    def exponent
        expr = unary
        while match_token(:CARET)
            operator = previous
            right = unary
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end
        return expr
    end

    def unary
        if match_token(:NOT, :MINUS, :EXCLAMATION)
            operator = previous
            right = unary
            return UnaryExpression.new(operator, right)
            # TODO: define this expression.
        end
        return call
    end

    def call
        expr = primary

        while match_token(:LEFT_PAREN)
            expr = finish_call(expr)
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
        return FunctionCallExpression.new(callee, paren, args)
    end

    def primary
        if match_token(:STRING_LITERAL)
            return primitive_literal(:string, previous.literal, previous)
        end
        if match_token(:BOOLEAN_LITERAL)
            return primitive_literal(:bool, previous.literal, previous)
        end        
        if match_token(:INTEGER_LITERAL)
            return primitive_literal(:int, previous.literal, previous)
        end
        if match_token(:REAL_LITERAL)
            return primitive_literal(:real, previous.literal, previous)
        end
        if match_token(:RATIONAL_LITERAL)
            return primitive_literal(:rational, previous.literal, previous)
        end

        if match_token(:IDENTIFIER)
            return VariableExpression.new(previous, previous.lexeme)
        end

        raise fault(peek, "Expecting an expression. Got '#{peek.lexeme}'.")
    end

    def primitive_literal(type, value, token)
        case type
        when :string
            return LiteralExpression.new(token, escape_string(value.to_s), type)
        when :int
            return LiteralExpression.new(token, value.to_i, type)
        when :real
            return LiteralExpression.new(token, value.to_f, type)
        when :rational
            return LiteralExpression.new(token, value.to_r, type)
        when :bool
            return LiteralExpression.new(token, !!value, type)
        else
            raise "What kind of literal is this?"
        end
    end

end
