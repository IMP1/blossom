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
        Node.new(1, Label.new(Literal.new(4), :int, [])),
        Node.new(2, Label.new(Literal.new(2), :int, [])),
        Node.new(3, Label.new(Literal.new(3), :int, [])),
        Node.new(4, Label.new(Literal.new(1), :int, [])),
    ], 
    [
    ],
    {}
)


match_graph  = Graph.new(
    [
        Node.new(1, Label.new(Variable.new("x", :int), :int, [])),
        Node.new(2, Label.new(Variable.new("x", :int), :int, [])),
    ], 
    [], 
    {"x" => :int}
)
expr = BinaryOperator.new(:PLUS, Variable.new("x", :int), Literal.new(1))
result_graph = Graph.new(
    [
        Node.new(1, Label.new(nil, nil, [])),
        Node.new(2, Label.new(nil, nil, [])),
    ], 
    [], 
    {}
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

puts "Test completed."