require_relative '../test'

require_relative '../../objects/graph'
require_relative '../../objects/rule'
require_relative '../../objects/label'
require_relative '../../objects/label_value_expression'
require_relative '../../objects/rule_application'

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
    {}
)

match_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
    ], 
    [
        Edge.new(1, 2, Label.empty),
    ], 
    {}
)
result_graph  = Graph.new(
    [
        Node.new(1, Label.empty),
        Node.new(2, Label.empty),
    ], 
    [
    ], 
    {}
)
rule = Rule.new("r1", {}, match_graph, result_graph, nil, nil)

#----------------#
# Pre-Conditions #
#----------------#
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
assert(host_graph.edges.size == 1, "Graph should now have one edge.")

puts "Test completed."