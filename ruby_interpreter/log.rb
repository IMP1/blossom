require_relative 'console_colours'

class Log

    NONE    = 0
    FATAL   = 1
    ERROR   = 2
    WARNING = 3
    INFO    = 4
    DEBUG   = 5
    TRACE   = 6
    ALL     = 7

    def set_output(output)
        @output = output
    end

    def get_output
        return @output
    end

    def set_level(level)
        @importance_level = level
    end

    def get_level
        return @importance_level
    end

    def initialize(source, level=INFO, output=$stdout)
        @source = source
        @importance_level = level
        @output = output
    end

    def fatal(message)
        print ConsoleStyle::BOLD_ON + ConsoleStyle::FG_RED
        log(message, @source, FATAL)
    end

    def error(message)
        print ConsoleStyle::BOLD_ON + ConsoleStyle::FG_RED
        log(message, @source, ERROR)
    end

    def warn(message)
        print ConsoleStyle::BOLD_ON + ConsoleStyle::FG_YELLOW
        log(message, @source, WARNING)
    end

    def info(message)
        print ConsoleStyle::BOLD_ON
        log(message, @source, INFO)
    end

    def debug(message)
        log(message, @source, DEBUG)
    end

    # FG_BLACK   = "\33[30m" # set foreground color to black
    # FG_RED     = "\33[31m" # set foreground color to red
    # FG_GREEN   = "\33[32m" # set foreground color to green
    # FG_YELLOW  = "\33[33m" # set foreground color to yellow
    # FG_BLUE    = "\33[34m" # set foreground color to blue
    # FG_MAGENTA = "\33[35m" # set foreground color to magenta (purple)
    # FG_CYAN    = "\33[36m" # set foreground color to cyan
    # FG_WHITE   = "\33[37m" # set foreground color to white
    # FG_DEFAULT = "\33[39m" # set foreground color to default (white)

    def trace(message)
        log(message, @source, TRACE)
    end

    def log(obj, source, importance)
        return if importance > @importance_level
        prefix = "[#{source}] "
        message = obj.to_s.gsub("\n", "\n" + (" " * prefix.length))
        @output.puts prefix + message + ConsoleStyle::RESET
    end

end