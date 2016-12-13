package blossom.lang.instruction;

import blossom.lang.Graph;
import blossom.lang.Rule;

public class RuleInstruction extends Instruction {

    public final Rule rule;

    public RuleInstruction(Rule rule, Multiplicity multiplicity) {
        super(multiplicity);
        this.rule = rule;
    }

    protected Graph apply(final Graph g) {
        return rule.apply(g);
    }
    
}
