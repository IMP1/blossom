require_relative '../test'

#---------#
# Arrange #
#---------#
host_graph = Graph.new(
    [
        Node.new(1, Label.new(LiteralLabelExpression.new(4), :int, [])),
        Node.new(2, Label.new(LiteralLabelExpression.new(2), :int, [])),
        Node.new(3, Label.new(LiteralLabelExpression.new("a str"), :string, [])),
    ], 
    [
        Edge.new(1, 2, Label.empty),
        Edge.new(2, 3, Label.empty),
    ],
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.new(Variable.new("x", :string), :string, [])),
    ], 
    [], 
)
result_graph = Graph.new(
    [
        Node.new(1, Label.new(LiteralLabelExpression.new(0), LiteralLabelExpression.new(0).type, [])),
    ], 
    [], 
)
rule = Rule.new("r1", {"x" => :string}, match_graph, result_graph, nil, nil)
#----------------#
# Pre-Conditions #
#----------------#
assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
assert(host_graph.edges.size == 2, "Host graph should have two edges.")

#-----#
# Act #
#-----#
test_run = Test.run(true) {

    application = RuleApplication.new(rule, host_graph)
    application.attempt

}

#-----------------#
# Post-Conditions #
#-----------------#
test_run.ensure do |result|
    result_graph = result.value

    assert(result_graph.nodes.size == 3, "Result graph should have three nodes.")
    assert(result_graph.edges.size == 2, "Result graph should have two edges.")

    assert(result_graph.nodes.count {|n| !n.label.nil? && !n.label.value.nil? && n.label.value.value == 0 } > 0)
end