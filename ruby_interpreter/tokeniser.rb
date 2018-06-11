require_relative 'main'
require_relative 'token'
require_relative 'error'

class Tokeniser

    KEYWORDS = {
        'rule'      => :RULE_DEF,
        'proc'      => :PROC_DEF,
        'where'     => :WHERE,
        'also'      => :ALSO,
        'unmarked'  => :UNMARKED,
        'void'      => :VOID,

        'noop'      => :NOOP,
        'invalid'   => :INVALID,

        'if'        => :IF,
        'with'      => :WITH,
        'try'       => :TRY,
    }

    def initialize(source, filename="")
        @filename = filename
        @source   = source

        @tokens  = []
        @start   = 0
        @current = 0
        @line    = 1
        @column  = 1
    end

    def tokenise
        while !eof?
            @start = @current
            scan_token
        end
        @tokens.push(Token.new(:EOF, "", @line, @column, @filename))
        return @tokens
    end

    def eof?
        return @current >= @source.length
    end

    def newline
        @line += 1
        @column = 1
    end

    def add_token(token_type, literal_value=nil)
        lexeme = @source[@start...@current]
        token = Token.new(token_type, lexeme, @line, @column, @filename, literal_value)
        @tokens.push(token)
    end

    def report_error(message)
        token = Token.new(:ERROR, @source[@start...@current], @line, @column, @filename)
        error = BlossomSyntaxError.new(token, message)
        Runner.syntax_error(error)
        return error
    end

    def advance
        @current += 1
        @column  += 1
        return @source[@current - 1]
    end

    def advance_if(expected)
        return false if eof?
        return false if @source[@current] != expected

        advance
        return true
    end

    def previous
        return @source[@current - 1]
    end

    def peek
        return nil if eof?
        return @source[@current]
    end

    def scan_token
        c = advance
        case c
        when '('
            add_token(:LEFT_PAREN)
        when ')'
            add_token(:RIGHT_PAREN)
        when '{'
            add_token(:LEFT_BRACE)
        when '}'
            add_token(:RIGHT_BRACE)
        when '['
            add_token(:LEFT_SQUARE)
        when ']'
            add_token(:RIGHT_SQUARE)

        when ','
            add_token(:COMMA)
        when ';'
            add_token(:SEMICOLON)
        when ':'
            add_token(:COLON)

        when '-'
            add_token(advance_if('>') ? :UNIDIRECTIONAL : :MINUS)
        when '+'
            add_token(:PLUS)
        when '*'
            add_token(:ASTERISK)
        when '%'
            add_token(:PERCENT)
        when '¬'
            add_token(:NOT)
        when '&'
            add_token(:AMPERSAND)
        when '|'
            add_token(:PIPE)
        when '?'
            add_token(:QUESTION)

        when '='
            if advance_if('>')
                add_token(:RIGHT_ARROW)
            else
                add_token(:EQUAL)
            end
        when '!'
            if advance_if('=')
                add_token(:NOT_EQUAL)
            else
                add_token(:NOT)
            end
        when '<'
            if advance_if('-') 
                if advance_if('>')
                    add_token(:BIDIRECTIONAL)
                else
                    add_token(:LESS)
                    add_token(:MINUS)
                end
            elsif advance_if('=')
                add_token(:LESS_EQUAL)
            else
                add_token(:LESS)
            end
        when '>'
            if advance_if('=')
                add_token(:GREATER_EQUAL)
            else
                add_token(:GREATER)
            end
        when '^'
            add_token(advance_if('=') ? :BEGINS_WITH : :CARET)
        when '$'
            add_token(:ENDS_WITH) if advance_if("=")
        when '~'
            add_token(:CONTAINS) if advance_if("=")


        when ' ', "\r", "\t"
            # do nothing
        when "\n"
            newline
            
        when "/"
            if advance_if("/")
                # Line comment:
                while !eof? && peek != "\n"
                    advance
                end
            else
                add_token(:STROKE)
            end

        when "#"
            mark

        when '"'
            string

        when /\d/
            number

        when /[a-zA-Z_]/
            identifier

        else
            report_error("Unexpected character '#{@source[@current-1]}'.")
        end
    end

    def mark
        while !eof? && !peek =~ /\s/
            advance
        end
        # Trim the leading `#`.
        value = @source[@start+1...@current]
        add_token(:MARK, value)
    end

    def string
        while !eof? && !(peek == '"' && previous != "\\")
            newline if peek == '\n'
            advance
        end

        if eof?
            report_error("Unterminated string.")
            return
        end

        # The closing ".
        advance();
        # Trim the surrounding quotes.
        value = @source[@start + 1...@current - 1]
        add_token(:STRING_LITERAL, value)
    end

    def number
        advance while peek =~ /[\d_]/

        if peek == '.' && peek_next =~ /\d/
            advance
            advance while peek =~ /\d/
            add_token(:REAL_LITERAL, @source[@start...@current].gsub("_", "").to_f)
        elsif peek == '/' && peek_next =~ /\d/
            advance
            advance while peek =~ /\d/
            add_token(:RATIONAL_LITERAL, @source[@start...@current].gsub("_", "").to_r)
        else
            add_token(:INTEGER_LITERAL, @source[@start...@current].gsub("_", "").to_i)
        end
    end

    def identifier
        advance while peek() =~ /[\w\?]/

        # See if the identifier is a reserved word.
        text = @source[@start...@current]

        # if VALUE_KEYWORDS.has_key?(text)
            # type  = VALUE_KEYWORDS[text][0]
            # value = VALUE_KEYWORDS[text][1]
            # add_token(type, value)
            # return
        # end

        # See if the identifier is a type.
        type = :IDENTIFIER
        type = KEYWORDS[text] if KEYWORDS.has_key?(text)

        add_token(type)
    end


end