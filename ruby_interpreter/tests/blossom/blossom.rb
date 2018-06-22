# rule_matching

require_relative '../test'

OUT_FILENAME = "temp-out.txt"

PROG_FILENAME = "./examples/blossom_algorithm.blsm"

Test.require do

    assert(File.exists?(PROG_FILENAME))

end

graph_text = '[1 (2), 2 (1), 3(3) | 1->2, 2->3, 1->3 ]'

$verbose = true

# Reset args
ARGV.reject! {true}
ARGV.push(PROG_FILENAME)
ARGV.push(graph_text)
ARGV.push("--output")
ARGV.push(OUT_FILENAME)

test_run = Test.run do

    load('./ruby_interpreter/blossom')

end

test_run.ensure do |result|

    assert(File.exists?(OUT_FILENAME))

end

File.delete(OUT_FILENAME)