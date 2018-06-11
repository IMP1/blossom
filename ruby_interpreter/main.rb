require_relative 'console_colours'

require_relative 'log'

require_relative 'tokeniser'
require_relative 'parser'

# Error Codes:
# https://stackoverflow.com/questions/1101957/are-there-any-standard-exit-status-codes-in-linux

class Runner

    class Exit < RuntimeError
        attr_reader :code
        def initialize(code)
            @code = code
        end
    end

    def self.syntax_error(error)
        @@compile_errors.push(error)
        report(error)
    end

    def self.compile_error(error)
        @@compile_errors.push(error)
        report(error)
    end

    def self.runtime_error(error)
        @@runtime_errors.push(error)
        report(error, true)
        exit(70)
    end

    def self.compile_errors
        return @@compile_errors
    end

    def self.runtime_errors
        return @@runtime_errors
    end

    def self.report(error, fatal=false)
        message =  "#{error.type}: #{error.message}\n"
        message += "      location: #{error.location}\n\n"
        if File.exists?(error.token.filename)
            message += ConsoleStyle::ITALICS_ON
            source = File.read(error.token.filename)
            lines = source.split(/\n/)
            from_line = [error.token.line-4, 0].max
            to_line   = [error.token.line+4, lines.size-1].min
            (from_line...to_line).each do |i|
                if i == (error.token.line - 1)
                    message += ConsoleStyle::BOLD_ON + lines[i] + ConsoleStyle::BOLD_OFF + "\n"
                else
                    message += lines[i] + "\n"
                end
            end
            message += ConsoleStyle::RESET + "\n"
        end
        if fatal
            @@log.fatal(message)
        else
            @@log.error(message)
        end
    end

    def self.run(prog_source, graph_source, prog_filename, graph_filename, log=nil)
        @@log = log || Log.new("Compiler")
        @@compile_errors = []
        @@runtime_errors = []

        tokeniser = Tokeniser.new(graph_source, graph_filename)
        graph_tokens = tokeniser.tokenise

        tokeniser = Tokeniser.new(prog_source, prog_filename)
        programme_tokens = tokeniser.tokenise

        parser = Parser.new(graph_tokens)
        graph = parser.parse_graph

        parser = Parser.new(programme_tokens)
        programme = parser.parse_programme

        return programme

        @@log.trace(tokens.map {|t| "\t<#{t.to_s}>"}.join("\n"))

        # return interpreter
    end

end