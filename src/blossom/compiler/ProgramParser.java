package blossom.compiler;

import java.util.ArrayList;
import java.util.regex.Pattern;

import blossom.lang.*;
import blossom.lang.instuction.*;
import blossom.lang.Rule.Variable;

public class ProgramParser extends Parser {

    private static final String  IDENTIFIER_REGEX = "[a-zA-Z_]\\w*\\??";
    public static final  Pattern IDENTIFIER = Pattern.compile(IDENTIFIER_REGEX);
    private static final Pattern TYPE = Pattern.compile("(?:int|string|colour|any)");
    private static final String  VARIABLE_LIST_REGEX = String.format("(%s)\\s*(%s\\s*(?:,\\s*%s)*)(?=;|>)", TYPE, IDENTIFIER, IDENTIFIER);
    private static final Pattern VARIABLE_LIST = Pattern.compile(VARIABLE_LIST_REGEX);
    private static final String  INSTRUCTION_REGEX = String.format("(%s)(;|!)?", IDENTIFIER, );
    private static final Pattern INSTRUCTION = Pattern.compile(INSTRUCTION_REGEX);

    private Programme programme;

    public ProgramParser(String programCode) {
        super(programCode);
        programme = new Programme();
    }

    public Programme parse() {
        consumeWhitespace();
        while (!eof()) {
            consumeWhitespace();
            if (beginsWith(Rule.DEFINITION_KEYWORD)) {
                parseRule();
            } else if (beginsWith(Procedure.DEFINITION_KEYWORD)) {
                parseProcedure();
            } else if (beginsWith(Graph.DEFINITION_KEYWORD)) {
                parseNamedGraph();
            } else {
                parseInstructions();
            }
        }
        return programme;
    }

    private void parseRule() {
        consume(Rule.DEFINITION_KEYWORD);
        consumeWhitespace();
        String ruleName = consume(IDENTIFIER);
        consumeWhitespace();
        ArrayList<Variable> variables = null;
        if (beginsWith("<")) {
            variables = parseRuleVariables();
            consumeWhitespace();
        }
        Graph initialGraph = parseGraph();
        consumeWhitespace();
        consume(Rule.APPLICATION_OPERATOR);
        consumeWhitespace();
        Graph resultGraph = parseGraph();
        consumeWhitespace();
        String condition = null;
        if (beginsWith(Rule.CONDITION_KEYWORD)) {
            condition = null; // TODO
        }
        consume(";");

        Rule rule = new Rule(initialGraph, resultGraph, variables, condition);
        programme.addRule(ruleName, rule);
    }

    private ArrayList<Variable> parseRuleVariables() {
        ArrayList<Variable> result = new ArrayList<Variable>();
        consume("<");
        while (!eof() && !beginsWith(">")) {
            String[] variables = consumeAll(VARIABLE_LIST);
            String type = variables[0];
            String[] names = variables[1].split("\\s*,\\s*");
            for (String name : names) {
                result.add(new Variable(type, name));
            }
        }
        consume(">");
        return result;
    }

    private void parseProcedure() {
        consume(Procedure.DEFINITION_KEYWORD);
        consumeWhitespace();
        String procName = consume(IDENTIFIER);
        consumeWhitespace();
        Procedure procedure = new Procedure();
        while (!eof() && !beginsWith(Procedure.END_KEYWORD)) {
            // TODO; add instructions to procedure.
        }
        consume(Procedure.END_KEYWORD);
        programme.addProcedure(procName, procedure);
    }

    private void parseInstructions() {
        if (beginsWith(Instruction.IF_KEYWORD)) {
            parseIfInstruction();
        } else if (beginsWith(Instruction.WITH_KEYWORD)) {
            parseWithInstruction();
        } else if (beginsWith(Instruction.TRY_KEYWORD)) {
            parseTryInstruction();
        } else if (beginsWith("{")) {
            parseInstructionGroup();
        } else if (beginsWith(IDENTIFIER)) {
            parseInstructionSequence();
        }

        // <instruction> ::= <proc_call> 
        //                 | <instruction>! 
        //                 | <instruction>;
        //                 | {<instruction_group>}
        //                 | try(<instruction>) 
        //                 | if(<instruction>, <instruction>)
        //                 | if(<instruction>, <instruction>, <instruction>)
        //                 | with(<instruction>, <instruction>)
        //                 | with(<instruction>, <instruction>, <instruction>)
        // <instruction_group> ::= <instruction> | <instruction>, <instruction_group>
        // <proc_call> ::= <rule_name> | <proc_name>

        // single_rule_or_proc_call
        // x;
        // x!
        // {x, y}
        // try(x)
        // if (x, y)
        // if (x, y, z)
        // with (x, y)
        // with (x, y, z)
    }

    private void parseIfInstruction() {

    }

    private void parseWithInstruction() {

    }

    private void parseTryInstruction() {
        consume(Instruction.TRY_KEYWORD);
        consumeWhitespace();
        consume("(");
        consumeWhitespace();
        parseInstructions();
        consumeWhitespace();
        consume(")");
    }

    private void parseInstructionGroup() {
        consume("{");
        consumeWhitespace();
        parseInstructions();
        consumeWhitespace();
        while (!eof() && !beginsWith("}")) {
            consume(",");
            consumeWhitespace();
            parseInstructions();
            consumeWhitespace();
        }
        consumeOptionalComma();
    }

    private void parseInstructionSequence() {
        String name = consume(IDENTIFIER);
    }

    private Graph parseGraph() {
        StringBuilder graphText = new StringBuilder();
        while (!eof() && !beginsWith("]")) {
            graphText.append(consume(Pattern.compile(".*?(?=\"|\\])")));
            if (beginsWith("\"")) {
                graphText.append(consume(Pattern.compile("\".*?(?<!\\\\)\"")));
            }
        }
        GraphParser gp = new GraphParser(graphText.toString(), true);
        return gp.parse();
    }

    private void parseNamedGraph() {
        consume(Graph.DEFINITION_KEYWORD);
        consumeWhitespace();
        String graphName = consume(IDENTIFIER);
        consumeWhitespace();
        Graph graph = parseGraph();
    }

    private void consumeOptionalComma() {
        if (beginsWith(",")) consume(",");
    }

}
