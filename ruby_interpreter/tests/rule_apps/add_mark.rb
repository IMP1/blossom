require_relative '../test'

require_relative '../../objects/graph'
require_relative '../../objects/rule'
require_relative '../../objects/label'
require_relative '../../objects/label_value_expression'
require_relative '../../objects/rule_application'

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
        Edge.new(1, 2, Label.empty),
        Edge.new(2, 3, Label.empty),
    ],
    {}
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
    ], 
    [], 
    {}
)
result_graph = Graph.new(
    [
        Node.new(1, Label.new(Literal.new(0), Literal.new(0).type, ["#foo"])),
    ], 
    [], 
    {}
)
rule = Rule.new("r1", {}, match_graph, result_graph, nil, nil)
#----------------#
# Pre-Conditions #
#----------------#
Test.require do
    assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
    assert(host_graph.edges.size == 2, "Host graph should have two edges.")
end

#-----#
# Act #
#-----#
test_run = Test.run {

    application = RuleApplication.new(rule, host_graph)
    application.attempt

}

test_run.ensure do |result|

    assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
    assert(host_graph.edges.size == 2, "Host graph should have two edges.")

    assert(host_graph.nodes.count {|n| !n.label.nil? && !n.label.value.nil? && n.label.value.value == 0 } > 0)

end
