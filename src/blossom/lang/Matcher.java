package blossom.lang;

import java.util.HashMap;

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
        return false;
    }

    private boolean nodesMatch(Node n1, Node n2) {

    }

}