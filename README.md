# Blossom

Blossom is a Programming Languages for graphs.
Heavily influenced by [GP2](https://github.com/UoYCS-plasma/GP2), being developed at the University of York, Blossom shares many of the same features.

## Blossom Syntax

Blossom does not have classes, or arrays, or structs. Instead it has *graphs*. Graphs are made up of *nodes* and *edges*. Both nodes and edges can have labels, which are lists of both integers and strings.

```blossom
    
# Graph Example:



```

Graphs are manipulated by *rules*, which are the most basic operators of Blossom. A rule has an *initial subgraph*, and a *resultant subgrah*. These are both graphs. Applying a rule to a graph will search within that graph for a match of the rule's initial subgraph, and will attempt to transform it into the resultant subgraph. If no match is found, or the resultant subgraph is invalid, then the rule application has failed.

```blossom

# Rule Example:



```

A *procedure* is comprised of rules. It can be sequential rule after rule, it can be a choice of rules, it can be an if-statement, or a try-statement.
Blossom is non-deterministic. 

Choosing arbitrarily between procedure is simple: `{r1, r2}`. If r1 cannot be applied, and r2 can, then r2 definitely will (and vice versa). But if they are both applicable, then one is chosen non-deterministically (in theory).

Looping a procedure is based on a as-many-times-as-possible loop: `r1!`. This will apply r1 for as many times as it can be applied.

If statements apply a procedure if the "condition" procedure terminates with a valid graph, and can have an optional else procedure: `(if r1, r2)` `(if r1, r2, r3)`

Try statements are the same. The difference is the result of the condition. With an if statement, the changes to the graph made by the "condition" procedure are not kept, whereas they are with a try statement: `(try r1, r2)` `(try r1, r2, r3)`

```blossom

# Programme Example:


```
