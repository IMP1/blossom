package blossom.lang.instruction;

import blossom.lang.Graph;

public class IfInstruction extends Instruction {

    public final Instruction condition;
    public final Instruction thenInstruction;
    public final Instruction elseInstruction;

    public IfInstruction(Instruction  condition, 
                         Instruction  thenInstruction, 
                         Multiplicity multiplicity) {
        this(condition, thenInstruction, null, multiplicity);
    }

    public IfInstruction(Instruction  condition, 
                         Instruction  thenInstruction, 
                         Instruction  elseInstruction, 
                         Multiplicity multiplicity) {
        super(multiplicity);
        this.condition = condition;
        this.thenInstruction = thenInstruction;
        this.elseInstruction = elseInstruction;
    }

    public Graph apply(final Graph g) {
        Graph postCondition = condition.apply(g);
        if (postCondition != Graph.INVALID) {
            return thenInstruction.apply(g);
        } else if (elseInstruction != null) {
            return elseInstruction.apply(g);
        } else {
            return Graph.INVALID; // TODO: should this be what is returned?
        }
    }
    
}
