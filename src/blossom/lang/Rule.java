package blossom.lang;

import java.util.ArrayList;

public class Rule {

    public class Variable {

        public enum Type {
            INT, STRING, COLOUR, ANY
        }

        public final Type type;
        public final String name;

    }

    public static final String DEFINITION_KEYWORD = "rule";

    public final ArrayList<Variable> variables;
    public final Graph initialGraph;
    public final Graph resultGraph;
    public final String condition;
    
    public Rule(Graph initialGraph, Graph resultGraph) {
        this(null, initialGraph, resultGraph);
    }

    public Rule(ArrayList<Variable> variables, Graph initialGraph, Graph resultGraph) {
        this(variables, initialGraph, resultGraph, null);
    }

    public Rule(ArrayList<Variable> variables, Graph initialGraph, Graph resultGraph, String condition) {
        this.variables = variables;
        this.initialGraph = initialGraph;
        this.resultGraph = resultGraph;
        this.condition = condition;
    }
    
}
