package blossom.lang.instruction;

public class InstructionGroup extends Instruction {

    public final ArrayList<Instruction> instructions;

    public InstructionGroup(Multiplicity multiplicity) {
        super(multiplicity);
        instructions = new ArrayList<Instruction>();
    }

    public void addInstruction(Instruction i) {
        instructions.add(i);
    }

    public Graph apply(final Graph g) {
        int choice = Math.floor(Math.random() * instructions.size());
        System.out.printf("Choosing Instruction %s.\n", instructions.get(choice));
        return instructions.get(choice).apply(g);
    }
    
}
