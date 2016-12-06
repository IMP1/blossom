# Blossom

Blossom is a Programming Languages for graphs.
Heavily influenced by [GP2](https://github.com/UoYCS-plasma/GP2), being developed at the University of York, Blossom shares many of the same features.

## Blossom Syntax

Blossom does not have classes, or arrays, or structs. Instead it has *graphs*. Graphs are made up of *nodes* and *edges*. Both nodes and edges can have labels, which are lists. These lists can contain integers (no signifier), strings (wrapped in quotation marks), colours (prefixed with a hash sign). A label may also contain the keyword 'empty', meaning the list must have no value in. To only match the first item in the label list, you can specify that it can be followed by other values you don't care about with the `*`. `(5, *)` will match a list beginning with 5. The `*` also can match nothing, so the list might also possibly just contain 5. Likewise, `(*, 5)` will match a list ending with a 5, and `(*, 5, *)` will match a list that contains a 5 at any point.

```blossom
// Graph Example:
graph g = [
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

Graphs are manipulated by *rules*, which are the most basic operators of Blossom. A rule has an *initial subgraph*, and a *resultant subgrah*. These are both graphs. Applying a rule to a graph will search within that graph for a match of the rule's initial subgraph, and will attempt to transform it into the resultant subgraph. If no match is found, or the resultant subgraph is invalid, then the rule application has failed.

Nodes in subgraphs of rules as well as having constant values in their label lists, can also variables. These have a type (`int`, `string`, `colour`, `any`), which are specified in the rule's signiture. Rules can also be suffixed with a condition, using the `where` modifier.

```blossom
// Rule Example:

rule setup_tags = <int: x, k> [ 1 (x), 2 (empty) | 1 -> 2 (k) ] => [  1 (x), 2 (x + k) | 1 -> 2 (k) ];
rule reduce     = <int: x, y, k> [ 1 (x), 2 (y) | 1 -> 2 (k) ] => [ 1 (x), 2 (x + k) | 1 -> 2 (k) ] where (x + k < y);

```

A *procedure* is comprised of rules. It can be sequential rule after rule, it can be a choice of rules, it can be an if-statement, or a try-statement.
Blossom is non-deterministic. 

Choosing arbitrarily between procedure is simple: `{r1, r2}`. If r1 cannot be applied, and r2 can, then r2 definitely will (and vice versa). But if they are both applicable, then one is chosen non-deterministically (in theory).

Looping a procedure is based on a as-many-times-as-possible loop: `r1!`. This will apply r1 for as many times as it can be applied.

If statements apply a procedure if the "condition" procedure terminates with a valid graph, and can have an optional else procedure: `(if r1, r2)` `(if r1, r2, r3)`

Try statements are the same. The difference is the result of the condition. With an if statement, the changes to the graph made by the "condition" procedure are not kept, whereas they are with a try statement: `(try r1, r2)` `(try r1, r2, r3)`

```blossom
// Programme Example:

rule setup_tags = <int: x, k> [ 1 (x), 2 (empty) | 1 -> 2 (k) ] => [ 1 (x), 2 (x + k) | 1 -> 2 (k) ];
rule reduce     = <int: x, y, k> [ 1 (x), 2 (y) | 1 -> 2 (k) ] => [ 1 (x), 2 (x + k) | 1 -> 2 (k) ] where (x + k < y);

setup_tags! reduce!

```
