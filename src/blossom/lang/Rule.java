package blossom.lang;

import java.util.ArrayList;

public class Rule {

    public static class Variable {

        public enum Type {
            INT, STRING, COLOUR, ANY
        }

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
    
}
