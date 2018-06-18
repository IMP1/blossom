require_relative '../test'

require_relative '../../objects/graph'
require_relative '../../objects/rule'
require_relative '../../objects/label'
require_relative '../../objects/label_value_expression'
require_relative '../../objects/rule_application'

#---------#
# Arrange #
#---------#
nodes = [
    Node.new(1, nil),
    Node.new(2, nil),
    Node.new(3, nil),
]
edges = [
    Edge.new(1, 2, nil),
    Edge.new(2, 3, nil),
]
host_graph = Graph.new(nodes, edges, [])



nodes = [
    Node.new(1, nil),
]
edges = [
]
match_graph  = Graph.new(nodes, edges, [])

new_label_value = Literal.new(0)
nodes = [
    Node.new(1, Label.new(new_label_value, new_label_value.type, [])),
]
edges = [
]
result_graph = Graph.new(nodes, edges, [])
rule = Rule.new("r1", [], match_graph, result_graph, nil, nil)
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

assert(host_graph.nodes.count {|n| !n.label.nil? && !n.label.value.nil? && n.label.value.value == 0 } > 0)
