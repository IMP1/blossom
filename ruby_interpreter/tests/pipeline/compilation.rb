require_relative '../test'

require_relative '../../main'

PROG_TEXT = <<~HEREDOC
rule foo    [ 1, 2 | 1->2 ]
         => [ 1 ]
end
foo
HEREDOC

GRAPH_TEXT = "[1, 2, 3 | 1->2, 2->3 ]"

test_run = Test.run {

    Runner.run(PROG_TEXT, GRAPH_TEXT, "test", "test")

}

test_run.ensure do |result|

    result_graph = result.value

    assert(result_graph.nodes.size == 2, "Result graph should have two nodes.")
    assert(result_graph.edges.size == 1, "Result graph should have one edge.")

end
