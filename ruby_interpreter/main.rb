require_relative 'console_colours'
require_relative 'exit_code'

require_relative 'log'

require_relative 'tokeniser'
require_relative 'parser'
require_relative 'printer'
require_relative 'type_checker'
require_relative 'interpreter'

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
        setup if !self.class.class_variable_defined? :@@log
        @@compile_errors.push(error)
        report(error)
    end

    def self.compile_error(error)
        setup if !self.class.class_variable_defined? :@@log
        @@compile_errors.push(error)
        report(error)
    end

    def self.runtime_error(error)
        setup if !self.class.class_variable_defined? :@@log
        @@runtime_errors.push(error)
        report(error, true)
        exit(ExitCode::SOFTWARE)
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

    def self.setup(log=nil)
        @@log = log || Log.new("Blossom")
        @@log.set_level(Log::ALL) if $verbose
        @@compile_errors = []
        @@runtime_errors = []
    end

    def self.run(prog_source, graph_source, prog_filename, graph_filename, only_validate=false)
        # TODO: if only_validate, output errors more programme-friendly (eg. remove colours)
        setup

        tokeniser = Tokeniser.new(graph_source, graph_filename)
        graph_tokens = tokeniser.tokenise

        tokeniser = Tokeniser.new(prog_source, prog_filename)
        programme_tokens = tokeniser.tokenise

        @@log.trace("Graph Tokens:")
        @@log.trace(graph_tokens.map {|t| "<#{t.to_s}>"}.join("\n"))
        @@log.trace("Programme Tokens:")
        @@log.trace(programme_tokens.map {|t| "<#{t.to_s}>"}.join("\n"))

        parser = Parser.new(graph_tokens)
        graph = parser.parse_graph

        type_checker = TypeChecker.new(nil)
        type_checker.check_graph(graph)

        parser = Parser.new(programme_tokens)
        programme = parser.parse_programme

        @@log.trace("Graph:")
        printer = Printer.new(graph)
        @@log.trace(printer.print_graph)
        @@log.trace("Programme:")
        printer = Printer.new(programme)
        @@log.trace(printer.print_programme)

        @@log.trace("Type Checking...")
        type_checker = TypeChecker.new(programme)
        type_checker.check_programme

        if !@@compile_errors.empty?
            exit(ExitCode::DATAERR)
        end

        if only_validate
            puts "Validation successful."
            exit(ExitCode::OK)
        end

        @@log.trace("Interpreting...")
        interpreter = Interpreter.new(graph, programme)

        result_graph = interpreter.interpret

        return result_graph
    end

end