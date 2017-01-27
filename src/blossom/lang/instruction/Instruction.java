package blossom.lang.instruction;

import blossom.lang.Graph;

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
    	Graph result;
        switch (multiplicity) {
        case OPTIONAL:
            result = apply(g);
            return result == Graph.INVALID ? g : result;
        case ONCE:
            return apply(g);
        case WHILE_POSSIBLE:
            result = g;
            Graph currentGraph = apply(g);
            while (currentGraph != Graph.INVALID) {
                result = currentGraph;
                currentGraph = apply(currentGraph);
            }
            return result;
        default:
        	return Graph.INVALID;
        }
    }

    protected abstract Graph apply(final Graph g);

    private static class NoOpInstruction extends Instruction {

        private NoOpInstruction() {
            super(Multiplicity.ONCE);
        }

        public Graph apply(final Graph g) {
            return g;
        }
        
    }

    public static final Instruction NOOP = new NoOpInstruction();
    public static final String NOOP_KEYWORD = "noop";
    
    private static class InvalidInstruction extends Instruction {
        
        private InvalidInstruction() {
            super(Multiplicity.ONCE);
        }
        
        public Graph apply(final Graph g) {
            return Graph.INVALID;
        }
        
    }
    
    public static final Instruction INVALID = new InvalidInstruction();
    public static final String INVALID_KEYWORD = "invalid";
    
}
