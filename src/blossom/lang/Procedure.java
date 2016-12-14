package blossom.lang;

import blossom.lang.instruction.Instruction;
import blossom.lang.instruction.InstructionSequence;

public class Procedure {

    public static final String DEFINITION_KEYWORD = "proc";
	public static final String END_KEYWORD = "end";

    public final InstructionSequence instructions;
    
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
