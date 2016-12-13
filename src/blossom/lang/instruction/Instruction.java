package blossom.lang.instruction;

import java.util.ArrayList;

public abstract class Instruction {

    public static final String IF_KEYWORD   = "if";
    public static final String WITH_KEYWORD = "with";
    public static final String TRY_KEYWORD  = "try";

    public enum Multiplicity {
        ONCE,
        OPTIONAL,
        WHILE_POSSIBLE
    }

    public final Multiplicity multiplicity;

    public Instruction(Multiplicity multiplicity) {
        this.multiplicity = multiplicity;
    }

    public Graph execute(final Graph g) {
        switch (multiplicity) {
        case OPTIONAL:
            Graph result = apply(g);
            return result == Graph.INVALID ? g : result;
        case ONCE:
            return apply(g);
        case WHILE_POSSIBLE:
            Graph result = g;
            Graph currentGraph = apply(g);
            while (currentGraph != Graph.INVALID) {
                result = currentGraph;
                currentGraph = apply(currentGraph);
            }
            return result;
        }
    }

    protected abstract Graph apply(final Graph g);
    
}
