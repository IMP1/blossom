package blossom.compiler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;

import blossom.lang.*;
import blossom.lang.instruction.*;
import blossom.lang.instruction.Instruction.Multiplicity;
import blossom.lang.Rule.Variable;

public class ProgramParser extends Parser {

    private static final String  IDENTIFIER_REGEX = "[a-zA-Z_]\\w*\\??";
    public static final  Pattern IDENTIFIER = Pattern.compile(IDENTIFIER_REGEX);

    private Programme programme;
    private HashMap<String, Rule> rules;
    private HashMap<String, Procedure> procedures;

    public ProgramParser(String programCode) {
        super(programCode);
        programme  = new Programme();
        rules      = new HashMap<String, Rule>();
        procedures = new HashMap<String, Procedure>();
    }

    public Programme parse() {
        if (verbose) logger.push("Parsing Programme...");
        consumeWhitespace();
        while (!eof()) {
            if (beginsWith("//")) {
                consumeLineComment();
            } else if (beginsWith(Rule.DEFINITION_KEYWORD)) {
                parseRule();
            } 
            /*
            else if (beginsWith(Graph.DEFINITION_KEYWORD)) {
                parseNamedGraph();
            } 
            */
            else if (beginsWith(Procedure.DEFINITION_KEYWORD)) {
                parseProcedure();
            } else {
                parseInstructionCall();
            }
            consumeWhitespace();
        }
        if (verbose) logger.pop("Parsed Programme.");
        return programme;
    }

    private void parseRule() {
        RuleParser rp = new RuleParser(text.substring(position));
        Rule rule = rp.parse();
        position += rp.position;
        programme.addRule(rule.name, rule);
        rules.put(rule.name, rule);
    }

    // private void parseNamedGraph() {
    //     if (verbose) logger.push("Parsing Graph Declaration...");
    //     // TODO: allow for variables
    //     consume(Graph.DEFINITION_KEYWORD);
    //     consumeWhitespace();
    //     String graphName = consume(IDENTIFIER);
    //     consumeWhitespace();
    //     Graph graph = parseGraph(null);
    //     programme.addGraph(graphName, graph);
    //     if (verbose) logger.pop("Parsed Graph Declaration.");
    // }

    private void parseProcedure() {
        if (verbose) logger.push("Parsing Procedure...");
        consume(Procedure.DEFINITION_KEYWORD);
        consumeWhitespace();
        String procName = consume(IDENTIFIER);
        consumeWhitespace();
        Procedure procedure = new Procedure();
        while (!eof() && !beginsWith(Procedure.END_KEYWORD)) {
            // TODO: add instructions to procedure.
        }
        consume(Procedure.END_KEYWORD);
        addProcedure(procName, procedure);
        if (verbose) logger.pop("Parsed Procedure.");
    }

    private void addProcedure(String name, Procedure proc) {
        programme.addProcedure(name, proc);
        procedures.put(name, proc);
    }
    
    private void parseInstructionCall() {
        InstructionParser ip = new InstructionParser(text.substring(position), rules, procedures);
        Instruction instruction = ip.parse();
        position += ip.position;
        programme.addInstruction(instruction);
    }

    private void consumeLineComment() {
        if (verbose) logger.push("Parsing Comment...");
        consume("//");
        consumeRestOfLine();
        if (verbose) logger.pop("Parsed Comment.");
    }

}
