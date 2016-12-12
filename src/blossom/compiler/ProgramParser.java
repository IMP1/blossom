package blossom.compiler;

import java.util.ArrayList;
import java.util.regex.Pattern;

import blossom.lang.Graph;
import blossom.lang.Procedure;
import blossom.lang.Programme;
import blossom.lang.Rule;
import blossom.lang.Rule.Variable;

public class ProgramParser extends Parser {

    private static final Pattern IDENTIFIER = Pattern.compile("[a-zA-Z_]\\w*");
    private static final Pattern TYPE = Pattern.compile("(?:int|string|colour|any)");
    private static final String  VARIABLE_LIST_REGEX = String.format("(%s)\\s*(%s\\s*(?:,\\s*%s)*)(?=;|>)", TYPE, IDENTIFIER, IDENTIFIER);
    private static final Pattern VARIABLE_LIST = Pattern.compile(VARIABLE_LIST_REGEX);

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
                parseInstruction();
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

    private void parseInstruction() {
        
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

}
