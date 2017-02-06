# Blossom

Blossom is a Programming Languages for graphs.
Heavily influenced by [GP2](https://www.cs.york.ac.uk/plasma/wiki/index.php?title=GP_(Graph_Programs)) ([Github](https://github.com/UoYCS-plasma/GP2)), 
being developed at the University of York, Blossom shares many of the same features.

## Blossom Syntax

### Graphs

Blossom does not have classes, or arrays, or structs. Instead it has *graphs*. Graphs are made up of *nodes* and *edges*.
Both nodes and edges can have labels, which are an optional *value*, and a set of *marks*.
These values can contain be (no signifier), strings (wrapped in quotation marks), or booleans (true/false).
A mark is a flag, prefixed with a '#', and these can be turned on or off for a node or edge.
A label may also contain the keyword 'unmarked', meaning the set of marks must be the empty set.
If a node or edge's label is empty, then it has no value, and its list of marks is null.

```blossom
// Graph Example:
graph g [
    // node-id [([node_value] [, node_mark [, ...]])]
    1 ('top side', 
    2 ('left island'),
    3 ('right island', #red),
    4 ('bottom side', #green),
|
    // source-id [<]-> target-id [(edge-label [, ...])]
    1 <-> 2 (4),
    1 <-> 2 (2),
    2 <-> 3 (6),
    2 <-> 3 (3),
    1 <-> 4 (1),
    2 <-> 4 (2),
    3 <-> 4 (1), // the last comma is optional, but is totally allowed.
]
```

The '|' can be omitted if the graph contains no edges. Whitespace is not important.

### Rules

Graphs are manipulated by *rules*, which are the most basic operators of Blossom. A rule has an *initial subgraph*, and a *resultant subgrah*. 
These are both graphs. Applying a rule to a graph will search within that graph for a match of the rule's initial subgraph, 
and will attempt to transform it into the resultant subgraph. If no match is found, or the resultant subgraph is invalid, then the rule application has failed.

Nodes in subgraphs of rules as well as having constant values in their label lists, can also variables. 
These have a type (`int`, `string`, `bool`, `any`), which are specified in the rule's signiture. 

#### Label Operations

Various operations can be applied to labels of nodes and edges. These depend on the label's type.
Integer operations include, in order or precedence:

 1. `^` exponent
 2. `/` division
 3. `*` multiplication
 4. `+` addition
 5. `-` subtraction
 6. `%` modulo

Boolean operations include, in order of precedence:

 1. `¬`/`not` not
 2. `&`/`and` and
 3. `|`/`or`  or
 4. `^`/`xor` xor

<!-- 
String functions include:

 sub(string text, int from [, int to]) -> string


-->

Rules can also be suffixed with a condition, using the `where` modifier. These conditions can use the inbuilt functions 

  * `in(node_id) -> int`: returns the number of edges with the node specified by `node_id` as their target.
  * `out(node_id) -> int`: returns the number of edges with the node specified by `node_id` as their source.
  * `edge(source_id, target_id) -> int`: returnsthe number of edges from the node specified by `source_id` to the node specified be `target_id`.
  * `adj(node_1_id, node_2_id) -> int`: returns the number of edges in either direction between the two nodes.

Conditions can also query values of nodes, or the existence (or non-existence) of marks.
Equality is done with a single equals (since there is no assignment operator to get confused with).
These can be combined with the logical operators `and`, `or`, `xor`, and `not`, which use [Polish Notation](https://en.wikipedia.org/wiki/Polish_notation).

If no label is specified in the initial graph of a rule, then it will match any label. To specify a node or edge with no value, use the `void` keyword, 
and as mentioned above the `unmarked` keyword will match nodes and edges with no marks. You can search for a node or edge where its label does not contain a mark, with the `¬markname` syntax.
If no label is specified for a node in the result graph of a rule, then it will retain its label from the initial graph. 
If the node did not exist in the initial graph, then it will have an empty label.

Despite the two previous points, it is advised to be explicit when using labels. 

Note that edges are always destroyed and recreated, and so omitting a label in the result graph will not retain the label from the initial graph, as it will always be a new edge.

As well as rule conditions, rules can also have an *addendum*. This is generally used for debugging or for file I/O. It uses the `also` keyword and executes the following statement when the rule application takes place. Any variable use values from before the rule application. See the [Turing Complete example](https://github.com/IMP1/blossom/tree/master/examples/turing_complete.blsm) for an example for this.

```blossom
// Rule Example:

rule setup_tags <int: x, k> [ 1 (x), 2 (empty) | 1 -> 2 (k) ] => [  1 (x), 2 (x + k) | 1 -> 2 (k) ];

rule reduce 
    <int: x, y, k> 
    [ 
        1 (x), 
        2 (y) 
    | 
        1 -> 2 (k) 
    ]
    =>
    [ 
        1 (x), 
        2 (x + k) 
    | 
        1 -> 2 (k) 
    ] 
    where (x + k < y);
```

### Programmes

A *procedure* is made up of rules. It can be a single rule, or sequential rule after rule, or a choice of rules. 
It can be an if-statement, or a with-statement, or a try-statement. A programme is made up of one or more procedures.

Blossom is non-deterministic, which affects its feature-set.

Choosing arbitrarily between procedure is simple: `{r1, r2}`. Either r1 or r2 is chosen non-deterministically (in theory). 

Looping a procedure is based on a as-many-times-as-possible loop: `r1!`. This will apply r1 for as many times as it can be applied.

To optionally apply a rule, there is the 'try' statement. `try(r1)` will attempt to apply r1, but if r1 fails the try will revert back to the graph before, 
and return that, counting as a successful application of the try statement.

If statements apply a procedure if the "condition" procedure terminates with a valid graph, and can have an optional else procedure: `if (r1, r2)` `if (r1, r2, r3)`
If the else procedure is omittied, it can be thought of that an implicit NOOP takes its place.
An if statement can return an invalid graph if the condition holds and the 'then' procedure fails, or if the condition fails, and the 'else' procedure fails.

'With' statements are very similar to if statements. The difference is the result of the condition. 
With an if statement, the changes to the graph made by the "condition" procedure are not kept before going on to either the 'then' or 'else' procedure, 
whereas with a 'with' statement the 'then' procedure uses the result of the condition procedure: `with (r1, r2)` `with (r1, r2, r3)`

```blossom
// Programme Example:

rule setup_tags
    <int: x, k>
    [ 1 (x), 2 (empty) | 1 -> 2 (k) ] => [ 1 (x), 2 (x + k) | 1 -> 2 (k) ];
rule reduce
    <int: x, y, k>
    [ 1 (x), 2 (y) | 1 -> 2 (k) ] => [ 1 (x), 2 (x + k) | 1 -> 2 (k) ]
    where (x + k < y);

setup_tags! reduce!
```

There are example programmes in the [Examples folder](https://github.com/IMP1/blossom/tree/master/examples) of the github project that show the syntax features.

## Running Blossom

Programmes can be thought of as functions, that take a single input of a graph. As such, both the programme and a *host graph* need to be given to actually execute a programme.

**Input**:
By default blossom checks for any command line arguments that are a graph, and then checks whether any graph arguments have been piped to it. If you pass the -i flag, you can specify a file to be read containing a graph.

`blossom connected_points -i "initial_graph"`

`blossom connected_points "[ 1, 2, 3 | 1->2, 2->3, 3->1 ]"`

`"[ 1, 2, 3 | 1->2, 2->3, 3->1 ]" | blossom connected_points`

**Output**:
By default, blossom outputs its output to the standard output. You can instead specify a file as the destination with the -o flag.

`blossom connected_points -o "resultant_graph"`

By default, blossom outputs a graph as text (or the special-case graph `invalid`). The text outputted is in the format blossom uses to represent graphs. You can pass certain flags to change the output format. For example, to output in the dot/graphviz output, you can pass the -dot flag.

`blossom connected_points -i "some_filename" -dot`