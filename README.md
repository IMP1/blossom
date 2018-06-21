# Blossom

Blossom is a programming language for programming on, and with, directed graphs (here on out referred to just as 'graphs').
It was heavily influenced by [GP2](https://www.cs.york.ac.uk/plasma/wiki/index.php?title=GP_(Graph_Programs)) ([Github](https://github.com/UoYCS-plasma/GP2)), which is being developed at the University of York.
Blossom shares many of the same core ideas.

Blossom does not have classes, or arrays, or structs. Instead it has *graphs*. Graphs are made up of *nodes* and *edges*.
Both nodes and edges can have labels, which are an optional *value* (integer, booleans, or string for example) associated with that node/edge.

Blossom also doesn't have functions or subroutines. Instead it has *rules*, and *rule applications*.
A rule defines a matching graph, and a resultant graph. The application of a rule is dependent on the matching graph being 'found' in a given graph.
The rule application then applies the changes between its matching graph and its resultant graph to the given graph.

## Installation & Running

### Installation

An interpreter for blossom is current still in development. 
When it's in a more stable state it should be released more formally, with install instructions and the such.
At the moment, however, in order to test the interpreter, you can clone this project, and run `./ruby_interpreter/blossom`, 
passing it a blossom programme file, and a host graph on which to run the programme.

### Running

Programmes can be thought of as functions, that take a single input of a graph. As such, both the programme and a *host graph* need to be given to actually execute a programme.

**Output**:

By default, blossom outputs the final resultant graph to the standard output. You can instead specify a file as the destination with the `-o`/`--output` flag.

`blossom connected_points.blsm -o "resultant_graph.bg"`

Blossom outputs a graph as text (or the special-case graph `invalid`). By default, this text is in the format blossom uses to represent graphs. 
You can pass certain flags to change the output format. For example, to output in the dot/graphviz output, you can pass the `--dot` flag.

`blossom connected_points.blsm -i "some_filename.dot" --dot`


**Input**:

By default blossom checks the first command line argument for a graph, and then checks whether any graph arguments have been piped to it. If you pass the -i flag, you can specify a file to be read containing a graph.

`blossom connected_points.blsm -i "initial_graph.bg"`

`blossom connected_points.blsm "[ 1, 2, 3 | 1->2, 2->3, 3->1 ]"`

`"[ 1, 2, 3 | 1->2, 2->3, 3->1 ]" | blossom connected_points.blsm`


## Examples

This example shows a blossom programme for finding the minimum distances of each other node from a given node in a graph. 
It expects a graph with an at least one node with a numbered label (usually 0 for the shortest-path problem), 
and all edges to have numbered labels representing their distance. 
It returns a graph with nodes' labels being their distance from this original node.

```blossom
rule init_tags 
    <int x, k>
    [ 1 (x), 2 (void) | 1->2 (k) ]
 => [ 1 (x), 2 (x + k) | 1->2 (k) ];

rule reduce
    <int x, y, k>
    [ 1 (x), 2 (y) | 1->2 (k) ]
 => [ 1 (x), 2 (x + k) | 1->2 (k) ]
where x + k < y;

init_tags! reduce!
```

This examples highlights the expressive power of blossom. 
Two rules are defined: one which makes sure the graph is in a state where the second can be applied, 
by giving all nodes without a label an initial numeric value; 
and the second rule reduces these nodes' labels values where possible.

Running both of these rules for as long as they can be applied will find the minimum distance from the original node to each other node.

<!-- 
    TODO: add a graphical representation of the rules (and the programme in general) to show off.
-->

## Documentation

<!-- 
    TODO: fix these links, and in the definitions case, add this page!
-->

For the syntax of blossom, take a look at the [Blossom Syntax](https://github.com/IMP1/blossom/) pages.

For a more formal definition of blossom and its workings, take a look at [Blossom Definition](https://github.com/IMP1/blossom/) pages.

