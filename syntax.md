# Graphs

The simplest graph is empty. A graph in blossom is denoted with square brackets (`[]`)

```blossom
[]
```

## Nodes

You can add nodes to a graph. They are given unique integer IDs, and have options labels, with optional marks.
They are in the format `{unique_int_id} ({label} [, #{mark_name} [, #{mark_name} ...]])`.
Whitespace is optional, so format graphs in as readable a way as you can. The three graphs are equivilent:

```blossom
[ 1, 2 ]
[ 
    1, 
    2 
]
[1,2]
```

A node can have a label, which can be an integer, a real number, a boolean or a string.

```blossom
[
    1 ('node number 1'),
    2 (20.2),
    3 (13),
    4,
    5 (false),
]
```



## Edges

# Rules

A

```blossom
rule foo [ 1 ] => [ 1 ] 