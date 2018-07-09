require_relative 'console_colours'
require_relative 'exit_code'

require_relative 'log'

require_relative 'tracer'

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
        @@compile_errors.push(error)
    end

    def self.compile_error(error)
        @@compile_errors.push(error)
    end

    def self.runtime_error(error)
        @@runtime_errors.push(error)
        report(error)
        exit(ExitCode::SOFTWARE)
    end

    def self.compile_errors
        return @@compile_errors
    end

    def self.runtime_errors
        return @@runtime_errors
    end

    def self.report(error, plain=false)
        message = error_report(error, plain)
        if plain
            puts message
        else
            @@log.error(message)
        end
    end

    def self.error_report(error, plain=false)
        message = ""
        message += ConsoleStyle::BOLD_ON unless plain
        message += "#{error.type}: #{error.message}\n"
        message += "\tlocation: #{error.location}\n\n"
        message += ConsoleStyle::BOLD_OFF unless plain
        if File.exists?(error.token.filename) && !plain
            message += ConsoleStyle::ITALICS_ON
            source = File.read(error.token.filename)
            lines = source.split(/\n/)
            from_line = [error.token.line-4, 0].max
            to_line   = [error.token.line+4, lines.size-1].min
            (from_line...to_line).each do |i|
                if i == (error.token.line - 1)
                    message += ConsoleStyle::BOLD_ON
                    message += lines[i] 
                    message += ConsoleStyle::BOLD_OFF
                    message += "\n"
                else
                    message += lines[i] + "\n"
                end
            end
            message += ConsoleStyle::RESET
            message += "\n"
        end
        return message
    end

    def self.setup(log=nil)
        @@log = log || Log.new("Blossom")
        @@log.set_level(Log::ALL) if $verbose
        @@compile_errors = []
        @@runtime_errors = []
    end

    # options
    #     only_validate:   boolean
    #     tracing:         boolean
    #     trace_dir:       string (path)
    def self.run(prog_source, graph_source, prog_filename, graph_filename, options=nil)
        options ||= {}
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

        if !@@compile_errors.empty?
            @@compile_errors.each { |e| report(e, options[:only_validate]) }
            exit(ExitCode::DATAERR)
        end

        parser = Parser.new(programme_tokens)
        programme = parser.parse_programme

        @@log.trace("Graph:")
        printer = Printer.new(graph)
        @@log.trace(printer.print_graph)
        @@log.trace("Programme:")
        printer = Printer.new(programme)
        @@log.trace(printer.print_programme)

        type_checker = TypeChecker.new(nil)
        type_checker.check_graph(graph)

        @@log.trace("Type Checking...")
        type_checker = TypeChecker.new(programme)
        type_checker.check_programme

        if !@@compile_errors.empty?
            @@compile_errors.each { |e| report(e, options[:only_validate]) }
            exit(ExitCode::DATAERR)
        end

        if options[:only_validate]
            puts "Validation successful."
            exit(ExitCode::OK)
        end

        if options[:tracing]
            trace_location = options[:trace_dir]
            tracer = Tracer.new(trace_location)
        else
            tracer = nil
        end

        @@log.trace("Interpreting...")
        interpreter = Interpreter.new(graph, programme, tracer)

        result_graph = interpreter.interpret

        return result_graph
    end

end