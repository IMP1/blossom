package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.Rule.Variable;

public class Matcher {

    private Graph                     hostGraph;
    private Rule                      rule;
    private Graph                     applicationGraph;
    private ArrayList<Variable>       variables;

    private HashMap<Integer, Integer> nodeMappings;

    public Matcher(Graph hostGraph, Rule rule) {
        this.hostGraph        = hostGraph;
        this.rule             = rule;
        this.applicationGraph = rule.initialGraph;
        this.variables        = rule.variables;
        this.nodeMappings     = new HashMap<Integer, Integer>();
    }

    public boolean find() {
        return false; // TODO: do
    }
    
    public HashMap<Integer, Integer> nextMatch() {
    	return null; // TODO: do.
    }

    private boolean nodesMatch(Node n1, Node n2) {
    	return false; // TODO: do
    }

}