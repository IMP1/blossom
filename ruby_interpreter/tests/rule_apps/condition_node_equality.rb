require_relative '../test'

#---------#
# Arrange #
#---------#
host_graph = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
        Node.new(3, Label.empty),
    ], 
    [
    ],
)

match_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
    ], 
    [], 
)
result_graph = Graph.new(
    [
        Node.new(1, Label.new(LiteralLabelExpression.new(0), LiteralLabelExpression.new(0).type, [])),
        Node.new(2, Label.new(LiteralLabelExpression.new(0), LiteralLabelExpression.new(0).type, [])),
    ], 
    [], 
)
condition = BinaryOperator.new(
    :NOT_EQUAL,
    FunctionCall.new(
        Function.node,
        [LiteralLabelExpression.new(1)]
    ),
    FunctionCall.new(
        Function.node,
        [LiteralLabelExpression.new(2)]
    )
)
rule = Rule.new("r1", {}, match_graph, result_graph, condition, nil)
#----------------#
# Pre-Conditions #
#----------------#
Test.require do
    assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
end

#-----#
# Act #
#-----#
test_run = Test.run {

    application = RuleApplication.new(rule, host_graph)
    application.attempt

}

test_run.ensure do |result|

    result_graph = result.value

    assert(result_graph.nodes.size == 3, "Result graph should have three nodes.")

    assert(result_graph.nodes.count {|n| !n.label.nil? && !n.label.value.nil? && n.label.value.value == 0 } == 2)

end
