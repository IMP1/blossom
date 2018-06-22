require_relative '../test'

#---------#
# Arrange #
#---------#
host_graph = Graph.new(
    [
        Node.new(1, Label.new(LiteralLabelExpression.new(4), :int, [])),
        Node.new(2, Label.new(LiteralLabelExpression.new(2), :int, [])),
        Node.new(3, Label.new(LiteralLabelExpression.new(3), :int, [])),
        Node.new(4, Label.new(LiteralLabelExpression.new(2), :int, [])),
    ], 
    [
    ],
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.new(Variable.new("x", :int), :int, [])),
        Node.new(2, Label.new(Variable.new("x", :int), :int, [])),
    ], 
    [], 
)
expr = BinaryOperator.new(:PLUS, Variable.new("x", :int), LiteralLabelExpression.new(1))
result_graph = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
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
rule = Rule.new("r1", {"x" => :int}, match_graph, result_graph, nil, nil)

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

    assert(result_graph.nodes.count { |n| n&.label&.value&.value == 2 } < 2)

end
