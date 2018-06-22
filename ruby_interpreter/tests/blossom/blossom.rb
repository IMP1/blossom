# rule_matching

require_relative '../test'

OUT_FILENAME = "temp-out.txt"

PROG_FILENAME = "./examples/blossom_algorithm.blsm"

Test.require do

    assert(File.exists?(PROG_FILENAME))

end

graph_text = <<~HEREDOC
    [
        1 (2), 
        2 (1), 
        3,
        4,
        5,
        6,
        7,
    | 
        1->2, 
        2->3, 
        1->3,
        3->4,
        4->5,
        5->6,
        6->7,
        7->4,
    ]
HEREDOC

$verbose = true

# Reset args
ARGV.insert(0, PROG_FILENAME)
ARGV.insert(1, graph_text)
ARGV.insert(2, "--output")
ARGV.insert(3, OUT_FILENAME)

test_run = Test.run do

    load('./ruby_interpreter/blossom')

end

test_run.ensure do |result|

    assert(File.exists?(OUT_FILENAME))
    puts File.read(OUT_FILENAME)

end

File.delete(OUT_FILENAME)