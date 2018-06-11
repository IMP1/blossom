class BlossomError < RuntimeError

    attr_reader :message
    attr_reader :token

    def initialize(token, message)
        @token = token
        @message = message
    end

    def location
        return @token.filename + ": [#{@token.line}, #{@token.column}]"
    end

    def type
        return self.class.name
    end

end

class BlossomSyntaxError < BlossomError
end

class BlossomParseError < BlossomError
end

class BlossomTypeError < BlossomParseError
end

class BlossomRuntimeError < BlossomError
end

class BlossomArgumentError < BlossomRuntimeError
end