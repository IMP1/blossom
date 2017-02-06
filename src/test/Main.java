package test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import blossom.compiler.GraphParser;
import blossom.compiler.ProgramParser;
import blossom.lang.Graph;
import blossom.lang.Node;
import blossom.lang.Programme;
import blossom.lang.Rule;

public class Main {
    
    public static void main(String... args) {
        testRules();
//        testProgramme();
//        testCompiler();
    }
    
    private static void testRules() {
        Graph LHS = new Graph();
        LHS.addNode(new Node(1));
        LHS.addNode(new Node(2));
        LHS.addEdge(1, 2);
        Graph RHS = new Graph();
        RHS.addNode(new Node(1));
        RHS.addNode(new Node(2));
        RHS.addEdge(2, 1);
        Rule r = new Rule(LHS, RHS);
        
        Graph g = new Graph();
        g.addNode(new Node(5));
        g.addNode(new Node(7));
        g.addEdge(5, 7);
        
        Graph h = r.apply(g);
        System.out.println("Initial Graph");
        System.out.println(g);
        System.out.println("Resultant Graph");
        System.out.println(h);
    }

    private static void testProgramme() {
        String graphText = "[ 1, 2, 3 | 1->2, 2->3 ]";
        GraphParser gp = new GraphParser(graphText, null);
        Graph g = gp.parse();
        System.out.println("\n");
        System.out.printf("Graph: '%s'.\n", g.toString());

        String programmeText = loadCode("examples/transativity.blsm");
        ProgramParser pp = new ProgramParser(programmeText);
        pp.verbose = true;
        Programme p = pp.parse();
        System.out.println("\n");
        System.out.printf("Programme: '%s'.\n", p.toString());

        Graph result = p.run(g);
        System.out.println(result);
    }

    private static void testCompiler() {
        // Compile the .jar
        // Make it executable
        // Pipe it some text
    }

    private static String loadCode(String filename) {
    	System.out.println(new File(".").getAbsolutePath());
        StringBuilder code = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ( (line = br.readLine()) != null ) {
               code.append(line);
               code.append("\n");
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return code.toString();
    }

}