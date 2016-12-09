package blossom.compiler;

public class ProgramParser extends Parser {
    
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

    }

    private void parseProcedure() {

    }

    private void parseInstruction() {
        
    }

}
