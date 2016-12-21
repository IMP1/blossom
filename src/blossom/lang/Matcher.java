package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.Rule.Variable;

public class Matcher {

    private Graph                     hostGraph;
    private Rule                      rule;
    private Graph                     applicationGraph;
    private ArrayList<Variable>       variables;

    private int skip = 0;
    
    private HashMap<Integer, Integer> nodeMappings;

    public Matcher(Graph hostGraph, Rule rule) {
        this.hostGraph        = hostGraph;
        this.rule             = rule;
        this.applicationGraph = rule.initialGraph;
        this.variables        = rule.variables;
        this.nodeMappings     = new HashMap<Integer, Integer>();
    }

    public boolean find() {
        return nextMatch() != null;
    }
    
    public HashMap<Integer, Integer> nextMatch() {
    	HashMap<Integer, Integer> match = new HashMap<Integer, Integer>();
    	for (int i = 0; i < rule.initialGraph.nodes().length; i ++) {
    		
    	}
    	return null; // TODO: do.
    }

    private boolean nodesMatch(Node hostGraphNode, Node applicationGraphNode) {
    	if (Functions.in(hostGraph, hostGraphNode.id) 
		 != Functions.in(applicationGraph, applicationGraphNode.id)) return false;
    	if (Functions.out(hostGraph, hostGraphNode.id) 
		 != Functions.out(applicationGraph, applicationGraphNode.id)) return false;
    	if (Functions.in(hostGraph, hostGraphNode.id) != Functions.in(applicationGraph, applicationGraphNode.id)) return false;
    	return false; // TODO: do
    }

}