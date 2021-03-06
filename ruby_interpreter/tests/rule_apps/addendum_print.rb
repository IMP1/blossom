require_relative '../test'

#---------#
# Arrange #
#---------#
host_graph = Graph.new(
    [
        Node.new(1, Label.new(LiteralLabelExpression.new(4), :int, [])),
        Node.new(2, Label.new(LiteralLabelExpression.new(2), :int, [])),
    ], 
    [
        Edge.new(1, 2, Label.empty),
        Edge.new(2, 1, Label.empty),
    ],
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.new(Variable.new("x", :int), :int, [])),
    ], 
    [], 
)
expr = BinaryOperator.new(:PLUS, Variable.new("x", :int), LiteralLabelExpression.new(1))
result_graph = Graph.new(
    [
        Node.new(1, Label.new(expr, :int, [])),
    ], 
    [], 
)
addendum = ProcedureCall.new(
    Procedure.print,
    [FunctionCall.new(
        Function.node,
        [LiteralLabelExpression.new(1)]
    )]
)
rule = Rule.new("r1", {"x" => :string}, match_graph, result_graph, nil, addendum)
#----------------#
# Pre-Conditions #
#----------------#
Test.require do
    assert(host_graph.nodes.size == 2, "Host graph should have three nodes.")
    assert(host_graph.edges.size == 2, "Host graph should have two edges.")
end

#-----#
# Act #
#-----#
test_run = Test.run do

    application = RuleApplication.new(rule, host_graph)
    application.attempt

end

test_run.ensure do |result|
    result_graph = result.value

    assert(result_graph.nodes.size == 2, "Result graph should have three nodes.")
    assert(result_graph.edges.size == 2, "Result graph should have two edges.")

end
