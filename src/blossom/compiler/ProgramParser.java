package blossom.compiler;

public class ProgramParser extends Parser {

    private static final Pattern IDENTIFIER = Pattern.compile("[a-zA-Z_]\\w*");
    
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
        if (beginsWith("<")) {
            ArrayList<Variable> variables = parseRuleVariables();
            consumeWhitespace();
        }
    }

    private ArrayList<Variable> parseRuleVariables() {

    }

    private void parseProcedure() {

    }

    private void parseInstruction() {
        
    }

}
