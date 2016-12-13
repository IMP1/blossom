package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.instruction.Instruction;

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
        Graph currentGraph = hostGraph;
        for (Instruction instruction : instructions) {
            currentGraph = instruction.execute(currentGraph);
        }
        return currentGraph;
    }

}
