# rule_matching

require_relative '../test'

TEMP_FILENAME = "temp.blsm"
OUT_FILENAME = "temp-out.txt"

prog_text = <<~HEREDOC
    rule foo    
        <int x, y>
        [ 1 (x), 2 (y) | 1->2 (void) ]
     => [ 1 (x), 2 (-y) | 1->2 (0) ]
        where node(1) != node(2);

    foo
HEREDOC

File.open(TEMP_FILENAME, 'w') do |f| 
    f.write(prog_text)
end

Test.require do

    assert(File.exists?(TEMP_FILENAME))

end

graph_text = '[1 (2), 2 (1), 3(3) | 1->2, 2->3, 1->3 ]'

$verbose = true

# Reset args
ARGV.reject! {true}
ARGV.push(TEMP_FILENAME)
ARGV.push(graph_text)
ARGV.push("--output")
ARGV.push(OUT_FILENAME)

test_run = Test.run do

    load('./ruby_interpreter/blossom')

end

test_run.ensure do |result|

    assert(File.exists?(OUT_FILENAME))

end

File.delete(TEMP_FILENAME)
File.delete(OUT_FILENAME)