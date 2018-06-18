require_relative 'log'
require_relative 'main'
require_relative 'error'

require_relative 'expression'
require_relative 'statement'

class Parser

    def initialize(tokens)
        @log = Log.new("Parser")
        @tokens = tokens
        @current = 0

        @rules = {}
        @procs = {}
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
        parameters ||= {}
        open_bracket_token = consume_token(:LEFT_SQUARE, "Expecting '[' to start a graph.")
        nodes = []
        edges = []
        while !eof? && !check(:PIPE) && !check(:RIGHT_SQUARE)
            nodes.push(parse_node)
            break if !match_token(:COMMA)
        end
        if match_token(:PIPE)
            while !eof? && !check(:RIGHT_SQUARE)
                edges.push(*parse_edge)
                break if !match_token(:COMMA)
            end
        end
        consume_token(:RIGHT_SQUARE, "Expecting '[' to end a graph.")
        return GraphExpression.new(open_bracket_token, nodes, edges, parameters)
    end

    #--------------------------------------------------------------------------#
    #                            Grammar Functions                             #
    #--------------------------------------------------------------------------#

    #------------------------------------#
    # Blossom Graph Grammar Nonterminals #
    #------------------------------------#
    def parse_node
        node_id_token = consume_token(:INTEGER_LITERAL, "Expecting an id for the node.")
        if match_token(:LEFT_PAREN)
            node_label = parse_label
            consume_token(:RIGHT_PAREN, "Expecting ')' after a node's label.")
        else
            node_label = EmptyLabelExpression.new(node_id_token)
        end
        return NodeExpression.new(node_id_token, node_label)
    end

    def parse_label
        paren_token = previous
        if match_token(:EMPTY)
            return EmptyLabelExpression.new(paren_token)
        end
        value = parse_label_value
        markset = []
        if value.nil? || match_token(:COMMA)
            markset = parse_markset
        end
        return LabelExpression.new(paren_token, value, markset)
    end

    def parse_label_value
        if match_token(:ASTERISK)
            return AnyLabelValueExpression.new(previous)
        end
        if match_token(:BOOLEAN_LITERAL, :INTEGER_LITERAL, :RATIONAL_LITERAL, :REAL_LITERAL, :STRING_LITERAL)
            token = previous
            value = previous.literal
            return LiteralExpression.new(token, value, token.name)
        elsif match_token(:VOID)
            token = previous
            return VoidLabelValueExpression.new(token)
        else
            return expression
        # elsif match_token(:IDENTIFIER)
        #     token = previous
        #     var_name = previous.lexeme
        #     if parameters.has_key?(var_name)
        #         type = parameters[var_name][:type_name]
        #         return VariableExpression.new(token, var_name, type)
        #     else
        #         fault(token, "Unrecognised value for a label.")
        #     end
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

    def parse_edge
        source_id_token = consume_token(:INTEGER_LITERAL, "Expecting an id of a source node.")
        source_id = source_id_token.lexeme.to_i
        both_ways = false
        if match_token(:BIDIRECTIONAL)
            arrow_token = previous
            both_ways = true
        else
            arrow_token = consume_token(:UNIDIRECTIONAL, "Expecting an arrow (-> or <->) between the nodes' ids.")
        end
        target_id_token = consume_token(:INTEGER_LITERAL, "Expecting an id of a target node.")
        target_id = target_id_token.lexeme.to_i
        if match_token(:LEFT_PAREN)
            edge_label = parse_label
            consume_token(:RIGHT_PAREN, "Expecting ')' after an edge's label.")
        else
            edge_label = EmptyLabelExpression.new(arrow_token)
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
        if !match_token(:SEMICOLON, :END)
            raise fault(peek, "Expecting ';' or 'end' after a rule's definition.")
        end
        @rules[rule_name_token.lexeme] = rule_name_token
        return RuleDefinitionStatement.new(rule_name_token, parameters, match_graph, result_graph, condition, addendum)
    end

    def procedure_definition
        proc_keyword_token = previous
        proc_name_token = consume_token(:IDENTIFIER, "Expecting a name for the rule.")
        statements = []
        while !eof? && !(check(:SEMICOLON) || check(:END))
            statements.push(rule_application)
        end
        if !match_token(:SEMICOLON, :END)
            raise fault(peek, "Expecting ';' or 'end' after a procedure's definition.")
        end
        @procs[proc_name_token.lexeme] = proc_name_token
        return ProcedureDefinitionStatement.new(proc_name_token, statements)
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

    def rule_application
        application = rule_application_prefix
        if match_token(:EXCLAMATION)
            application = LoopStatement.new(previous, application)
        end
        return application
    end

    def rule_application_prefix
        if match_token(:TRY)
            keyword_token = previous
            consume_token(:LEFT_PAREN, "Expecting '(' before a try statement.")
            attempt = sequence
            consume_token(:RIGHT_PAREN, "Expecting ')' after a try statment.")
            return TryStatement.new(keyword_token, attempt)
        end
        if match_token(:IF)
            keyword_token = previous
            consume_token(:LEFT_PAREN, "Expecting '(' before an if statement.")
            condition = rule_application
            consume_token(:COLON, "Expecting ':' after an if statement's condition.")
            then_stmt = rule_application
            else_stmt = nil
            if match_token(:COLON)
                else_stmt = rule_application
            end
            consume_token(:RIGHT_PAREN, "Expecting ')' after an if statment.")
            return IfStatement.new(keyword_token, condition, then_stmt, else_stmt)
        end
        if match_token(:WITH)
            keyword_token = previous
            consume_token( :LEFT_PAREN, "Expecting '(' before a with statement.", ")")
            condition = rule_application
            consume_token(:COLON, "Expecting ':' after a with statement's condition.")
            then_stmt = rule_application
            else_stmt = nil
            if match_token(:COLON)
                else_stmt = rule_application
            end
            consume_token(:RIGHT_PAREN, "Expecting ')' after a with statment.")
            return WithStatement.new(keyword_token, condition, then_stmt, else_stmt)
        end
        if match_token(:LEFT_PAREN)
            paren_token = previous
            applications = sequence
            consume_token(:RIGHT_PAREN, "Expecting ')' after a rule application sequence")
            return SequenceStatement.new(paren_token, applications)
        end
        if match_token(:LEFT_BRACE)
            paren_token = previous
            applications = sequence
            consume_token(:RIGHT_BRACE, "Expecting '}' after a rule application set")
            return ChoiceStatement.new(paren_token, applications)
        end
        if match_token(:NOOP)
            return NoopStatement.new(previous)
        end
        if match_token(:INVALID)
            return InvalidStatement.new(previous)
        end
        if match_token(:IDENTIFIER)
            var_name_token = previous

            if @rules.has_key?(var_name_token.lexeme)
                return RuleApplicationStatement.new(var_name_token, var_name_token.lexeme)
            end
            if @procs.has_key?(var_name_token.lexeme)
                return ProcedureApplicationStatement.new(var_name_token, var_name_token.lexeme)
            end
            raise fault(var_name_token, "No rule or procedure found called '#{var_name_token.lexeme}'.")
        end
        raise fault(peek, "Expecting a rule application. Got '#{peek.lexeme}'.")
    end

    def sequence
        applications = []
        while !eof? && !check(:RIGHT_PAREN)
            applications.push(rule_application)
        end
        return applications
    end

    def statement
        return call # TODO: can statements be more complicated?
    end

    def expression
        return or_shortcircuit
    end

    def or_shortcircuit
        expr = and_shortcircuit

        while match_token(:PIPE, :OR)
            operator = previous
            right = and_shortcircuit
            expr = BinaryOperatorExpression.new(expr, operator, right)
        end

        return expr
    end

    def and_shortcircuit
        expr = equality

        while match_token(:AMPERSAND, :AND)
            operator = previous
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
            return UnaryOperatorExpression.new(operator, right)
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
        return FunctionCallExpression.new(callee, args)
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

        if match_token(:LEFT_PAREN)
            grouping_token = previous
            expr = expression
            consume_token(:RIGHT_PAREN, "Expecting ')' after expression.")
            return GroupingExpression.new(grouping_token, expr)
        end

        fault(peek, "Expecting an expression. Got '#{peek.lexeme}'.")
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
