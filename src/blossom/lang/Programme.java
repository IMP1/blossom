package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

public class Programme {

    private HashMap<String, Rule> rules;
    private HashMap<String, Procedure> procedures;
    private ArrayList<Instruction> instructions;
    
    public Programme() {

    }

    public void addRule(String name, Rule rule) {
        rules.put(name, rule);
    }

    public void addProcedure(String name, Procedure procedure) {
        procedures.put(name, procedure);
    }

    public void addInstruction(Instruction newInstruction) {
        instructions.add(newInstruction);
    }

    public Graph run(Graph hostGraph) {
        // TODO
    }

}
