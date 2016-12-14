package blossom.compiler;

import java.io.InputStreamReader;

import blossom.lang.Graph;

public class Compiler {
    
    private static void printUsage() {
        System.out.println("");
    }

    public static void main(String... args) throws Exception {
        // Allow for Piped-in Arguments
        try (InputStreamReader streamReader = new InputStreamReader(System.in)) {
            StringBuilder pipelineArgs = new StringBuilder();
            char[] buffer = new char [256];
            int amountRead = 0;
            while (streamReader.ready() && amountRead > -1) {
                amountRead = streamReader.read(buffer, 0, buffer.length);
                if (amountRead > -1) {
                    pipelineArgs.append(buffer, 0, amountRead);
                }
            }
            System.out.printf("Read '%s' from SYSIN.\n", pipelineArgs.toString());
        }

        // TODO: Handle both args and pipelineArgs
        // ...
        
    }

}
