package blossom.lang.instruction;

import blossom.lang.Graph;

public class WithInstruction extends Instruction {

    public final Instruction condition;
    public final Instruction thenInstruction;
    public final Instruction elseInstruction;

    public WithInstruction(Instruction  condition, 
                         Instruction  thenInstruction, 
                         Multiplicity multiplicity) {
        this(condition, thenInstruction, null, multiplicity);
    }

    public WithInstruction(Instruction  condition, 
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
            return thenInstruction.apply(postCondition);
        } else if (elseInstruction != null) {
            return elseInstruction.apply(g);
        } else {
            return Graph.INVALID; // TODO: should this be what is returned?
        }
    }
    
}
