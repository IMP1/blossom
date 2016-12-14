package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

import blossom.lang.instruction.Instruction;

public class Programme {

    private HashMap<String, Rule>      rules;
    private HashMap<String, Graph>     graphs;
    private HashMap<String, Procedure> procedures;
    private ArrayList<Instruction>     instructions;
    
    public Programme() {
        rules        = new HashMap<>();
        graphs       = new HashMap<>();
        procedures   = new HashMap<>();
        instructions = new ArrayList<>();
    }

    public void addGraph(String name, Graph graph) {
        // TODO: add check for overwriting.
        graphs.put(name, graph);
    }

    public void addRule(String name, Rule rule) {
        // TODO: add check for overwriting.
        rules.put(name, rule);
    }

    public void addProcedure(String name, Procedure procedure) {
        // TODO: add check for overwriting.
        procedures.put(name, procedure);
    }

    public void addInstruction(Instruction newInstruction) {
        instructions.add(newInstruction);
    }

    public Graph run(Graph hostGraph) {
        Graph currentGraph = hostGraph;
        for (Instruction instruction : instructions) {
            currentGraph = instruction.execute(currentGraph);
            if (currentGraph == Graph.INVALID) return Graph.INVALID;
        }
        return currentGraph;
    }
    
    @Override
    public String toString() {
    	StringBuilder s = new StringBuilder();
    	for (Instruction i : instructions) {
    		s.append(i).append("\n");
    	}
    	return s.toString();
    }

}
