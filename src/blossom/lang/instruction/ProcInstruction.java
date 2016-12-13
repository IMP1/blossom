package blossom.lang.instruction;

public class ProcInstruction extends Instruction {

    public final Procedure procedure;

    public ProcInstruction(Procedure procedure, Multiplicity multiplicity) {
        super(multiplicity);
        this.procedure = procedure;
    }

    protected Graph apply(final Graph g) {
        return rule.apply(g);
    }
    
}
