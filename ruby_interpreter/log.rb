class Log

    NONE    = 0
    FATAL   = 1
    ERROR   = 2
    WARNING = 3
    INFO    = 4
    DEBUG   = 5
    TRACE   = 6

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
        log(message, @source, FATAL)
    end

    def error(message)
        log(message, @source, ERROR)
    end

    def warn(message)
        log(message, @source, WARNING)
    end

    def info(message)
        log(message, @source, INFO)
    end

    def debug(message)
        log(message, @source, DEBUG)
    end

    def trace(message)
        log(message, @source, TRACE)
    end

    def log(obj, source, importance)
        return if importance > @importance_level
        prefix = "[#{source}] "
        message = obj.to_s.gsub("\n", "\n" + (" " * prefix.length))
        @output.puts "\n" + prefix + message
    end

end