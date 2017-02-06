package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.LabelItem.Type;

public class Rule {

    public static class Variable {

        public final Type type;
        public final String name;

        public Variable(String type, String name) {
            this(Type.valueOf(type.toUpperCase()), name);
        }

        public Variable(Type type, String name) {
            this.type = type;
            this.name = name;
        }

    }

    public static final String DEFINITION_KEYWORD   = "rule";
    public static final String CONDITION_KEYWORD    = "where";
    public static final String ADDENDUM_KEYWORD     = "also";
    public static final String APPLICATION_OPERATOR = "=>";

    public final String name;
    public final ArrayList<Variable> variables;
    public final Graph initialGraph;
    public final Graph resultGraph;
    public final Graph interfaceGraph;
    public final String condition;
    public final String addendum;
    
    public Rule(String name, Graph initialGraph, Graph resultGraph) {
        this(name, initialGraph, resultGraph, null);
    }

    public Rule(String name, Graph initialGraph, Graph resultGraph, ArrayList<Variable> variables) {
        this(name, initialGraph, resultGraph, variables, null);
    }

    public Rule(String name, Graph initialGraph, Graph resultGraph, ArrayList<Variable> variables, String condition) {
        this(name, initialGraph, resultGraph, variables, null, null);
    }

    public Rule(String name, Graph initialGraph, Graph resultGraph, ArrayList<Variable> variables, String condition, String addendum) {
        this.name           = name;
        this.variables      = variables;
        this.initialGraph   = initialGraph;
        this.resultGraph    = resultGraph;
        this.condition      = condition;
        this.addendum       = addendum
        this.interfaceGraph = createInterface();
    }

    public Graph apply(Graph hostGraph) {
        System.out.printf("Applying Rule...\n");

        // do some matching...
        //return hostGraph.remove( initialGraph.remove(interfaceGraph) )
        //                .add( resultGraph.remove(initialGraph) );


        /*
A rule r = L ← K → R consists of two inclusions K → L and K → R such that L,R are graphs
in G(C) and K, the interface of r, is a graph in G(C⊥). Intuitively, an application of r to a graph will
remove the items in L−K, preserve K, add the items in R−K, and relabel the unlabelled nodes in K.

 - From https://www.cs.york.ac.uk/plasma/publications/pdf/Plump.WRS.11.pdf
        */
        HashMap<Integer, Integer> mapping = Matcher.match(this, hostGraph);
        if (mapping == null) return Graph.INVALID;
        Graph L_minus_K = initialGraph.remove(interfaceGraph);
        System.out.println(L_minus_K);
        System.out.println(L_minus_K.map(mapping));
        
        Graph g = hostGraph.remove(L_minus_K.map(mapping));
        System.out.println(g);
        
        Graph R_minus_K = resultGraph.remove(interfaceGraph);
        System.out.println(R_minus_K);
        System.out.println(R_minus_K.map(mapping));
        
        Graph h = g.add(R_minus_K.map(mapping));
        System.out.println(h);
        
        return h;
    }

    private Graph createInterface() {
        Graph g = new Graph();
        for (Node n : initialGraph.nodes()) {
            if (resultGraph.hasNode(n.id)) {
                g.addNode(new Node(n.id));
            }
        }
        return g;
    }

    @Override
    public String toString() {
        return String.format("%s => %s", initialGraph.toStringCondensed(), 
                                         resultGraph.toStringCondensed());
    }
    
}
