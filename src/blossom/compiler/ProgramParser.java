package blossom.compiler;

public class ProgramParser extends Parser {

    private static final Pattern IDENTIFIER = Pattern.compile("[a-zA-Z_]\\w*");
    private static final Pattern TYPE = Pattern.compile("(?:int|string|colour|any)");
    private static final String  VARIABLE_LIST_REGEX = String.Format("(%s)\\s*(%s\\s*(?:,\\s*%s)*)(?=;|>)", TYPE, IDENTIFIER, IDENTIFIER);
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
            // TODO: add graph definitions?
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
            condition = null // TODO
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
        
    }

    private void parseInstruction() {
        
    }

    private void parseGraph() {
        
    }

}
