package blossom.lang.instruction;

public class InstructionSequence extends Instruction {

    public final ArrayList<Instruction> instructions;

    public InstructionSequence(Multiplicity multiplicity) {
        super(multiplicity);
        instructions = new ArrayList<Instruction>();
    }

    public void addInstruction(Instruction i) {
        instructions.add(i);
    }

    public Graph apply(final Graph g) {
        Graph currentGraph = g;
        for (Instruction instruction : instructions) {
            currentGraph = instruction.apply(currentGraph);
            if (currentGraph == Graph.INVALID) return currentGraph;
        }
        return currentGraph;
    }
    
}
