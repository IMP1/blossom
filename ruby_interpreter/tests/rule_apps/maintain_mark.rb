require_relative '../test'

#---------#
# Arrange #
#---------#
host_graph = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.new(nil, nil, ['#foo'])),
        Node.new(3, Label.empty),
    ], 
    [
        Edge.new(1, 2, Label.empty),
        Edge.new(2, 3, Label.empty),
    ],
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.new(nil, nil, ['#foo'])),
    ], 
    [], 
)
result_graph = Graph.new(
    [
        Node.new(1, Label.empty),
    ], 
    [], 
)
rule = Rule.new("r1", {}, match_graph, result_graph, nil, nil)
#----------------#
# Pre-Conditions #
#----------------#
assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
assert(host_graph.edges.size == 2, "Host graph should have two edges.")

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

    assert(result_graph.nodes.size == 3, "Host graph should have three nodes.")
    assert(result_graph.edges.size == 2, "Host graph should have two edges.")

    assert(result_graph.nodes.count {|n| !n.label.nil? && !n.label.markset.nil? && n.label.markset.size > 0 } > 0)

end
