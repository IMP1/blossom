package blossom.lang;

import java.util.ArrayList;

public class Procedure {

    public static final String DEFINITION_KEYWORD = "proc";
	public static final String END_KEYWORD = "end";

    private InstructionSequence instructions;
    
    public Procedure() {
        instructions = new InstructionSequence(Instruction.Multiplicity.ONCE);
    }

    public void addInstruction(Instruction i) {
        instructions.addInstruction(i);
    }

    public Graph apply(Graph g) {
        return instructions.apply(g);
    }

}
