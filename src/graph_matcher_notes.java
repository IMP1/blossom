/*
    Google 'subgraph isomorphism testing'
    http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0097178#s2
*/

public HashMap<Integer, Integer> match(HashMap<Integer, Integer> substitutions, Rule rule, Graph hostGraph, int depth) {
    for (Node ruleNode : rule.initialGraph.nodes()) {
        if (substitutions.containsKey(ruleNode.id)) continue;

        for (Node graphNode : hostGraph.nodes()) {
            if nodesMatch(ruleNode, graphNode) {
                substitutions.put(ruleNode.id, graphNode.id);
                HashMap<Integer, Integer> matchAttempt = match(substitutions, rule, hostGraph, depth + 1);
                if (matchAttempt == null) {
                    substitutions.remove(ruleNode.id);
                } else if (substitutions.size() == rule.initialGraph.nodes().length) {
                    return substitutions;
                }
            }
        }
    }
    if (substitutions.size() <= rule.initialGraph.nodes().length && depth == 0) {
        return null;
    } else {
        return substitutions;
    }
}

private boolean nodesMatch() {

}

private boolean testMatch(HashMap<Integer, Integer> substitutions, Rule rule, Graph hostGraph) {

}

/*
    Test Cases
    ----------

Trivial:

Rule:  [ 1 ] => [ 1 ];
Graph: [ 1 ]

Rule:  [] => [ 1 ];
Graph: []

Rule:  [ 1 ] => [];
Graph: [ 1, 2 ]


Simple:

Rule:  [ 1, 2 | 1->2 ] => [ 1, 2 | 1->2, 2->1 ];
Graph: []
Graph: [ 1 ]
Graph: [ 1, 2 ]
Graph: [ 1, 2 | 1->2 ]
Graph: [ 1, 2 | 2->1 ]

Rule:  [ 1 (2) ] => [ 1 (3) ]
Graph: [ 1 ("abc") ]
Graph: [ 1 (4) ]
Graph: [ 1 (2) ]

Rule: <int x> [ 1 (x) ] => [ 1 (x) ]
Graph: [ 1 ("abc") ]
Graph: [ 1 (4) ]

*/