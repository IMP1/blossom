package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.Rule.Variable;

public class Matcher {

    public static HashMap<Integer, Integer> getMatch(Graph hostGraph, Rule rule) {
    	return getMatch(new HashMap<Integer, Integer>(), hostGraph, rule, 0);
    }
    
    private static HashMap<Integer, Integer> getMatch(HashMap<Integer, Integer> substitutions, 
                                                      Graph hostGraph, 
                                                      Rule rule, 
                                                      int depth) {
        for (int i = 0; i < rule.initialGraph.nodes().length; i ++) {
            if (substitutions.containsKey(i)) continue;
            
            Node ruleNode = rule.initialGraph.nodes()[i];
            
            for (int j = 0; j < hostGraph.nodes().length; j ++) {
                Node graphNode = hostGraph.nodes()[i];
                
                if (nodesMatch(graphNode, ruleNode)) {
                    HashMap<Integer, Integer> subSubstitutions = (HashMap<Integer, Integer>)substitutions.clone();
                    subSubstitutions.put(i, j);
                    
                    subSubstitutions = getMatch(substitutions, hostGraph, rule, depth + 1);
                    if (subSubstitutions.size() == rule.initialGraph.nodes().length) {
                        boolean validMatch = testMatch(subSubstitutions);
                        if (validMatch) return subSubstitutions;
                    }
                            
                }
            }
        }
        return substitutions;
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