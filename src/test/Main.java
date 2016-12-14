package blossom.test;

import blossom.compiler.GraphParser;

public class Main {
    
    public static void main(String... args) {
        testProgramme();
        testCompiler();
    }

    private static void testProgramme() {
        String graphText = "[ 1 (#red), 2 (4) | 1->2 ]";
        Graph g = new GraphParser(graphText, null).parse();
        System.out.println(g);

        String programmeText = loadCode("../examples/swap_deltas.blsm");
        Programme p = new ProgrammeParser(programmeText).parse();
        System.out.println(p);

        Graph result = p.run(g);
        System.out.println(result);
    }

    private static void testCompiler() {
        // Compile the .jar
        // Make it executable
        // Pipe it some text
    }

    private static String loadCode(String filename) {
        StringBuilder code = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ( (line = br.readLine()) != null ) {
               code.append(line);
               code.append("\n");
            }
        }
        return code.toString();
    }

}