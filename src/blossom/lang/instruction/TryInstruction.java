package blossom.lang.instruction;

public class TryInstruction extends Instruction {

    public final Instruction instruction;

    public TryInstruction(Instruction instruction) {
        super(Multiplicity.OPTIONAL);
        this.instruction = instruction;
    }

    public Graph apply(final Graph g) {
        return instruction.apply(g);
    }
    
}
