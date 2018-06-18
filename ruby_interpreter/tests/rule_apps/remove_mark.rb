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
        Node.new(2, Label.new(nil, nil, ['#foo'])),
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
        Node.new(1, Label.new(nil, nil, ['#foo'])),
    ], 
    [], 
    {}
)
result_graph = Graph.new(
    [
        Node.new(1, Label.new(nil, nil, ['¬foo'])),
    ], 
    [], 
    {}
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
test_run = Test.run(true) {

    application = RuleApplication.new(rule, host_graph)
    application.attempt

}

#-----------------#
# Post-Conditions #
#-----------------#
assert(host_graph.nodes.size == 3, "Host graph should have three nodes.")
assert(host_graph.edges.size == 2, "Host graph should have two edges.")

assert(host_graph.nodes.count {|n| !n.label.nil? && !n.label.markset.nil? && n.label.markset.size > 0 } == 0)

puts "Test completed."