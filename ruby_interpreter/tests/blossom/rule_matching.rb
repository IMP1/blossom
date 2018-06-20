# rule_matching

prog_text = <<~HEREDOC
    rule foo    
        <int x, y>
        [ 1 (x), 2 (y) | 1->2 (empty) ]
     => [ 1 (x), 2 (y) | 1->2 (0) ];

    foo
HEREDOC

# TODO: save prog text into temp file

graph_text = "[1 (2), 2 (1), 3(3) | 1->2, 2->3, 1->3 ]"


# TOD: Run blossom with temp file and graph text.

./ruby_interpreter/blossom tmp.blsm ""

# TODO: delete temp file