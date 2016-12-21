package test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import blossom.compiler.GraphParser;
import blossom.compiler.ProgramParser;
import blossom.lang.Graph;
import blossom.lang.Programme;

public class Main {
    
    public static void main(String... args) {
        testProgramme();
//        testCompiler();
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