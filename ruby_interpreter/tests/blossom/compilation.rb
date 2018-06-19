require_relative '../test'

require_relative '../../main'

$verbose = true

#---------#
# Arrange #
#---------#

# dangling_condition

PROG_TEXT = <<~HEREDOC
rule foo    [ 1, 2 | 1->2 ]
         => [ 1 ]
end
foo
HEREDOC

GRAPH_TEXT = "[1, 2, 3 | 1->2, 2->3 ]"

#-----#
# Act #
#-----#
test_run = Test.run {

    # ARGV = ["tmp.blsm", "\"#{GRAPH_TEXT}\""]
    # require_relative 

    Runner.run(PROG_TEXT, GRAPH_TEXT, "test", "test")

}

test_run.ensure do |result|

    result_graph = result.value

    assert(result_graph.nodes.size == 2, "Result graph should have two nodes.")
    assert(result_graph.edges.size == 1, "Result graph should have one edge.")

end
