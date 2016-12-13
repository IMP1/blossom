package blossom.lang;

public class RuleInstruction extends Instruction {

    public final Rule rule;

    public RuleInstruction(Rule rule) {
        this.rule = rule;
    }

    public Graph execute(final Graph g) {
        switch (multiplicity) {
        case OPTIONAL:
            Graph result = rule.apply(g);
            return result == Graph.INVALID ? g : result;
        case ONCE:
            return rule.apply(g);
        case WHILE_POSSIBLE:
            Graph result = g;
            Graph currentGraph = rule.apply(g);
            while (currentGraph != Graph.INVALID) {
                result = currentGraph;
                currentGraph = rule.apply(currentGraph);
            }
            return result;
        }
    }
    
}
