# Blossom

Blossom is a Programming Languages for graphs.
Heavily influenced by [GP2](https://www.cs.york.ac.uk/plasma/wiki/index.php?title=GP_(Graph_Programs)) ([Github](https://github.com/UoYCS-plasma/GP2)), being developed at the University of York, Blossom shares many of the same features.

## Blossom Syntax

### Graphs

Blossom does not have classes, or arrays, or structs. Instead it has *graphs*. Graphs are made up of *nodes* and *edges*. Both nodes and edges can have labels, which are lists. These lists can contain integers (no signifier), strings (wrapped in quotation marks), colours (prefixed with a hash sign). A label may also contain the keyword 'empty', meaning the list must have no value in. To only match the first item in the label list, you can specify that it can be followed by other values you don't care about with the `*`. `(5, *)` will match a list beginning with 5. The `*` also can match nothing, so the list might also possibly just contain 5. Likewise, `(*, 5)` will match a list ending with a 5, and `(*, 5, *)` will match a list that contains a 5 at any point.

```blossom
// Graph Example:
graph g [
    // node-id [(node-label [, ...])]
    1 ('top side', 
    2 (#red, 'left island'),
    3 (#blue, 'right island'),
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

The '|' can be omitted if the graph contains no edges, and whitespace is not important.

### Rules

Graphs are manipulated by *rules*, which are the most basic operators of Blossom. A rule has an *initial subgraph*, and a *resultant subgrah*. These are both graphs. Applying a rule to a graph will search within that graph for a match of the rule's initial subgraph, and will attempt to transform it into the resultant subgraph. If no match is found, or the resultant subgraph is invalid, then the rule application has failed.

Nodes in subgraphs of rules as well as having constant values in their label lists, can also variables. These have a type (`int`, `string`, `colour`, `any`), which are specified in the rule's signiture. 

Rules can also be suffixed with a condition, using the `where` modifier. These conditions can use the inbuilt functions `in(node_id) -> int`, `out(node_id) -> int`, `edge?(source_id, target_id) -> bool`, `uedge(node_1_id, node_2_id)`; and can be combined with the logical operators `and`, `or`, and `not`.

If no label is specified in the initial graph of a rule, then it will match any label. To specify an empty label, use the `empty` keyword. 
If no label is specified in the result graph of a rule, then it will retain its label from the initial graph, or have an empty label if it is not found in the intial graph. Note that edges are always destroyed and recreated, and so omitting a label in the result graph will not retain the label from the initial graph, as it will be a new edge. To retain it, use a `list` variable.

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

A *procedure* is made up of rules. It can be a single rule, or sequential rule after rule, or a choice of rules. It can be an if-statement, or a with-statement, or a try-statement. A programme is made up of one or more procedures.

Blossom is non-deterministic, which affects its feature-set.

Choosing arbitrarily between procedure is simple: `{r1, r2}`. Either r1 or r2 is chosen non-deterministically (in theory). 

Looping a procedure is based on a as-many-times-as-possible loop: `r1!`. This will apply r1 for as many times as it can be applied.

To optionally apply a rule, there is the 'try' statement. `try(r1)` will attempt to apply r1, but if r1 fails the try will revert back to the graph before, and return that, counting as a successful application of the try statement.

If statements apply a procedure if the "condition" procedure terminates with a valid graph, and can have an optional else procedure: `if (r1, r2)` `if (r1, r2, r3)`

'With' statements are the same. The difference is the result of the condition. With an if statement, the changes to the graph made by the "condition" procedure are not kept before going on to either the 'then' or 'else' procedure., whereas with a 'with' statement the 'then' procedure uses the result of the condition procedure: `with (r1, r2)` `with (r1, r2, r3)`

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

<!-- 
### Syntactic Features

**Rules**:

 * <type var1, var2; type var3, var4; ...> : variable list for a rule
 * [ nodes | edges ] : graph
 * where ... : rule condition
 * and/or/not : logical operators for rule conditions
 * in/out/edge/uedge/... : built-in functions for rule conditions

** Graphs**:

 * [ nodes | edges ] : graph

** Programmes**:

 * r1; : rule/proc application
 * r1! : rule/proc looping
 * {r1, r2} : non-deterministic choice
 * try(r1) : optional application
 * if(r1, r2[, r3]) : conditional applications with rollback of condition
 * with(r1, r2[, r3]) : conditional applications without rollback of condition
 * rule <rule_definition> : rule definition
 * proc <proc_definition> end : procedure definition
    
-->

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