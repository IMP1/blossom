package blossom.lang.instruction;

import java.util.ArrayList;

import blossom.lang.Graph;

public class InstructionSequence extends Instruction {

    public final ArrayList<Instruction> instructions;

    public InstructionSequence(Multiplicity multiplicity) {    
        this(new ArrayList<Instruction>(), multiplicity);
    }

    public InstructionSequence(ArrayList<Instruction> instructions, Multiplicity multiplicity) {
        super(multiplicity);
        this.instructions = instructions;
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
