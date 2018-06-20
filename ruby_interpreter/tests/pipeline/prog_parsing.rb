require_relative '../test'

require_relative '../../tokeniser'
require_relative '../../parser'
require_relative '../../printer'

#---------#
# Arrange #
#---------#
prog_text = <<~HEREDOC
rule r1 [1] => [1];
proc p1 
    try(r1) r1! if(r1 : r1 r1 : r1)
end

p1! {r1, (p1 r1)} (r1 r1)
if (r1 : r1 p1)
try(p1 r1)
noop
invalid

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

    puts result.error
    puts result.error&.backtrace

    puts result.value

end
