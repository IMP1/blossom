package blossom.compiler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;

import blossom.lang.*;
import blossom.lang.instruction.*;
import blossom.lang.instruction.Instruction.Multiplicity;
import blossom.lang.Rule.Variable;

public class RuleParser extends Parser {

    private static final Pattern TYPE = Pattern.compile("(?:int|string|colour|any)");
    private static final String  VARIABLE_LIST_REGEX = String.format("(%s)\\s*(%s\\s*(?:,\\s*%s)*)(?=;|>)", 
                                                                     TYPE, ProgramParser.IDENTIFIER, ProgramParser.IDENTIFIER);
    private static final Pattern VARIABLE_LIST = Pattern.compile(VARIABLE_LIST_REGEX);

    public Rule parse() {
        if (verbose) logger.push("Parsing Rule...");
        consume(Rule.DEFINITION_KEYWORD);
        consumeWhitespace();
        String ruleName = consume(ProgramParser.IDENTIFIER);
        consumeWhitespace();
        
        ArrayList<Variable> variables = null;
        if (beginsWith("<")) {
            variables = parseRuleVariables();
            consumeWhitespace();
        }

        Graph initialGraph = parseGraph(variables);
        consumeWhitespace();
        consume(Rule.APPLICATION_OPERATOR);
        consumeWhitespace();
        Graph resultGraph = parseGraph(variables);
        consumeWhitespace();

        String condition = null;
        if (beginsWith(Rule.CONDITION_KEYWORD)) {
            condition = null; // TODO: add rule conditions
            consume(Pattern.compile(".*?(?=;|" + Rule.ADDENDUM_KEYWORD + ")"));
        }
        
        String addendum = null;
        if (beginsWith(Rule.ADDENDUM_KEYWORD)) {
            addendum = null;
            consume(Pattern.compile(".*?(?=;)"));
        }
        consume(";");

        Rule rule = new Rule(ruleName, initialGraph, resultGraph, variables, condition);
        if (verbose) logger.pop("Parsed Rule.");
        return rule;
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


}