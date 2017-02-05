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

package blossom.lang;

import java.util.HashMap;

public class Matcher {

//    public static HashMap<Integer, Integer> getMatch(Graph hostGraph, Rule rule) {
//    	return getMatch(new HashMap<Integer, Integer>(), hostGraph, rule, 0);
//    }
//    
//    private static HashMap<Integer, Integer> getMatch(HashMap<Integer, Integer> substitutions, 
//                                                      Graph hostGraph, 
//                                                      Rule rule, 
//                                                      int depth) {
//        for (int i = 0; i < rule.initialGraph.nodes().length; i ++) {
//            if (substitutions.containsKey(i)) continue;
//            
//            Node ruleNode = rule.initialGraph.nodes()[i];
//            
//            for (int j = 0; j < hostGraph.nodes().length; j ++) {
//                Node graphNode = hostGraph.nodes()[i];
//                
//                if (nodesMatch(graphNode, ruleNode)) {
//                    HashMap<Integer, Integer> subSubstitutions = (HashMap<Integer, Integer>)substitutions.clone();
//                    subSubstitutions.put(i, j);
//                    
//                    subSubstitutions = getMatch(substitutions, hostGraph, rule, depth + 1);
//                    if (subSubstitutions.size() == rule.initialGraph.nodes().length) {
//                        boolean validMatch = testMatch(subSubstitutions);
//                        if (validMatch) return subSubstitutions;
//                    }
//                            
//                }
//            }
//        }
//        return substitutions;
//    }
    
    public static HashMap<Integer, Integer> match(Rule rule, Graph hostGraph) {
        return match(new HashMap<Integer, Integer>(), rule, hostGraph, 0);
    }
    
    public static HashMap<Integer, Integer> match(HashMap<Integer, Integer> substitutions, Rule rule, Graph hostGraph, int depth) {
        for (Node ruleNode : rule.initialGraph.nodes()) {
            if (substitutions.containsKey(ruleNode.id)) continue;

            for (Node graphNode : hostGraph.nodes()) {
                if (nodesMatch(ruleNode, graphNode)) {
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
        if (substitutions.size() < rule.initialGraph.nodes().length && depth == 0) {
            return null;
        } else {
            return substitutions;
        }
    }
    
    private static boolean testMatch(HashMap<Integer, Integer> substitutions) {
        return true;
    }

    private static boolean nodesMatch(Node hostGraphNode, Node ruleGraphNode) {
        if (ruleGraphNode.label() != null) {
            for (String mark : ruleGraphNode.label().marks) {
                if (!hostGraphNode.label().hasMark(mark)) return false;
            }
        }
        return true;
    }

}