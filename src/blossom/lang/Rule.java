package blossom.lang;

import java.util.ArrayList;

public class Rule {

    public static final String DEFINITION_KEYWORD = "rule";

    public final Graph initialGraph;
    public final Graph resultGraph;
    // variables
    // conditions
    
    public Rule(Graph initialGraph, Graph resultGraph) {
        this.initialGraph = initialGraph;
        this.resultGraph = resultGraph;
    }
    
    
}
