require_relative '../test'

require_relative '../../tokeniser'
require_relative '../../parser'
require_relative '../../printer'

#---------#
# Arrange #
#---------#
prog_text = <<~HEREDOC
rule r1 [] => [];
HEREDOC

tokeniser = Tokeniser.new(prog_text, "rule_parsing:prog_text")
token_list = tokeniser.tokenise

parser = Parser.new(token_list)

#-----#
# Act #
#-----#
test_run = Test.run {

    parser.parse_programme

}

test_run.ensure do |result|

    assert(result.value)

end
