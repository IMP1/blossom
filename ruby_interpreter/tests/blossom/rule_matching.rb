# rule_matching

TEMP_FILENAME = "temp.blsm"

prog_text = <<~HEREDOC
    rule foo    
        <int x, y>
        [ 1 (x), 2 (y) | 1->2 (empty) ]
     => [ 1 (x), 2 (y) | 1->2 (0) ];

    foo
HEREDOC

File.open(TEMP_FILENAME, 'w') { |f| 
    f.write(prog_text)
}

graph_text = "[1 (2), 2 (1), 3(3) | 1->2, 2->3, 1->3 ]"


# Reset ARGV for blossom:
ARGV.reject! {true}
ARGV.push(TEMP_FILENAME)
ARGV.push(graph_text)

load('./ruby_interpreter/blossom')

File.delete(TEMP_FILENAME)