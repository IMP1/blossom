package blossom.compiler;

import blossom.lang.Graph;

public class Compiler {
    
    private static void printUsage() {
        System.out.println("");
    }

    public static void main(String... args) {
    	test();
        if (args.length == 0) {
            printUsage();
            return;
        }
        
    }
    
    public static void test() {
    	String graphText = "[ 1 (#red), 2 (4) | 1->2 ]";
    	Graph g = new GraphParser(graphText, false).parse();
    	System.out.println(g);
    }

}