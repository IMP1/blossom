require_relative '../test'

require_relative '../../tokeniser'

#---------#
# Arrange #
#---------#
prog_text = <<~HEREDOC
rule r1 [] => [];
HEREDOC

tokeniser = Tokeniser.new(prog_text, "rule_parsing:prog_text")

#-----#
# Act #
#-----#
test_run = Test.run {

    tokeniser.tokenise

}

test_run.ensure do |result|

    token_list = result.value

    assert(token_list.size > 0, "Result token list should be non-empty.")

    [
        Token.new(:RULE_DEF,     "", 0, 0, ""),
        Token.new(:IDENTIFIER,   "", 0, 0, ""),
        Token.new(:LEFT_SQUARE,  "", 0, 0, ""),
        Token.new(:RIGHT_SQUARE, "", 0, 0, ""),
        Token.new(:RIGHT_ARROW,  "", 0, 0, ""),
        Token.new(:LEFT_SQUARE,  "", 0, 0, ""),
        Token.new(:RIGHT_SQUARE, "", 0, 0, ""),
        Token.new(:SEMICOLON,    "", 0, 0, ""),
        Token.new(:EOF,          "", 0, 0, ""),
    ].each_with_index do |expected, i|
        assert(token_list[i].name == expected.name)
    end

end
