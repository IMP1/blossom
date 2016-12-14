package blossom.lang;

import java.util.ArrayList;

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
    }

    public Graph apply(Graph hostGraph) {
    	System.out.printf("Applying Rule...\n");
    	return hostGraph;
    	
//        Matcher m = new Matcher(hostGraph, this);
//        if (!m.find()) {
//            return Graph.INVALID;
//        }
//        HashMap<Integer, Integer> nodeMapping;
//        while ((nodeMapping = m.nextMatch()) != null) {
//            return hostGraph; // TODO: remove placeholder no-op.
//        }
//        return Graph.INVALID;
    }
    
    @Override
    public String toString() {
    	return String.format("%s => %s", initialGraph.toStringCondensed(), 
    			                         resultGraph.toStringCondensed());
    }
    
}
