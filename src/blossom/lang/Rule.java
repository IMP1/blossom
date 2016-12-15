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

    public static final String DEFINITION_KEYWORD = "rule";
    public static final String CONDITION_KEYWORD = "where";
    public static final String APPLICATION_OPERATOR = "=>";

    public final ArrayList<Variable> variables;
    public final Graph initialGraph;
    public final Graph resultGraph;
    public final Graph interfaceGraph;
    public final String condition;
    
    public Rule(Graph initialGraph, Graph resultGraph) {
        this(initialGraph, resultGraph, null);
    }

    public Rule(Graph initialGraph, Graph resultGraph, ArrayList<Variable> variables) {
        this(initialGraph, resultGraph, variables, null);
    }

    public Rule(Graph initialGraph, Graph resultGraph, ArrayList<Variable> variables, String condition) {
        this.variables = variables;
        this.initialGraph = initialGraph;
        this.resultGraph = resultGraph;
        this.condition = condition;
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
        
        Matcher m = new Matcher(hostGraph, this);
        if (!m.find()) {
            return Graph.INVALID;
        }
        HashMap<Integer, Integer> ruleToGraphNodeMapping;
        while ((ruleToGraphNodeMapping = m.nextMatch()) != null) {
            Graph L_minus_K = initialGraph.remove(interfaceGraph);
            System.out.println(L_minus_K);
            System.out.println(L_minus_K.map(ruleToGraphNodeMapping));
            
            Graph g = hostGraph.remove(L_minus_K.map(ruleToGraphNodeMapping));
            System.out.println(g);
            
            Graph R_minus_K = resultGraph.remove(interfaceGraph);
            System.out.println(R_minus_K);
            System.out.println(R_minus_K.map(ruleToGraphNodeMapping));
            
            Graph h = g.add(R_minus_K.map(ruleToGraphNodeMapping));
            System.out.println(h);
            
            return hostGraph; // TODO: remove placeholder no-op.
        }
        return Graph.INVALID;
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
