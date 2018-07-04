require_relative '../test'

#---------#
# Arrange #
#---------#

# Host Graph
host_graph = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
        Node.new(3, Label.empty),
    ], 
    [
        Edge.new(1, 2, Label.empty),
        Edge.new(2, 3, Label.empty),
    ], 
)

match_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
    ], 
    [
        Edge.new(1, 2, Label.empty),
    ], 
)
result_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
    ], 
    [
    ], 
)
rule = Rule.new("r1", {}, match_graph, result_graph, nil, nil)

#----------------#
# Pre-Conditions #
#----------------#
Test.require do
    assert(host_graph.edges.size == 2, "Host graph should have two edges.")
end

#-----#
# Act #
#-----#
test_run = Test.run {

    application = RuleApplication.new(rule, host_graph)
    application.attempt

}

#-----------------#
# Post-Conditions #
#-----------------#
test_run.ensure do |result|
    result_graph = result.value

    assert(result_graph.edges.size == 1, "Graph should now have one edge.")

end
