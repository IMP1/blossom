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
    private static final Pattern TYPE = Pattern.compile("(?:int|string|colour|any)");
    private static final String  VARIABLE_LIST_REGEX = String.format("(%s)\\s*(%s\\s*(?:,\\s*%s)*)(?=;|>)", TYPE, IDENTIFIER, IDENTIFIER);
    private static final Pattern VARIABLE_LIST = Pattern.compile(VARIABLE_LIST_REGEX);

    private static final HashMap<String, Runnable> BUILTIN_OPERATIONS = new HashMap<String, Runnable>();
    static {
        BUILTIN_OPERATIONS.put("print", (x) -> BuiltInOperation.print(x)); // TODO: add other procs, and see if this works.
    }

    private Programme programme;
    private HashMap<String, Rule> rules;
    private HashMap<String, Procedure> procedures;

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
            } else if (beginsWith(Graph.DEFINITION_KEYWORD)) {
                parseNamedGraph();
            } else if (beginsWith(Procedure.DEFINITION_KEYWORD)) {
                parseProcedure();
            } else {
                parseInstructionCall();
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
        Graph initialGraph = parseGraph(variables);
        consumeWhitespace();
        consume(Rule.APPLICATION_OPERATOR);
        consumeWhitespace();
        Graph resultGraph = parseGraph(variables);
        consumeWhitespace();
        String condition = null;
        if (beginsWith(Rule.CONDITION_KEYWORD)) {
            condition = null; // TODO: add rule conditions
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

    private Graph parseGraph(ArrayList<Variable> variables) {
        StringBuilder graphText = new StringBuilder();
        while (!eof() && !beginsWith("]")) {
            graphText.append(consume(Pattern.compile(".*?(?=\"|\\])")));
            if (beginsWith("\"")) {
                graphText.append(consume(Pattern.compile("\".*?(?<!\\\\)\"")));
            }
        }
        GraphParser gp = new GraphParser(graphText.toString(), variables);
        return gp.parse();
    }

    private void parseNamedGraph() {
        // TODO: allow for variables
        consume(Graph.DEFINITION_KEYWORD);
        consumeWhitespace();
        String graphName = consume(IDENTIFIER);
        consumeWhitespace();
        Graph graph = parseGraph(null);
        programme.addGraph(graphName, graph);
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

    private void parseInstructionCall() {
        Instruction i = parseInstruction();
        programme.addInstruction(i);
    }

    private Instruction parseInstruction() {
        if (beginsWith(Instruction.IF_KEYWORD)) {
            return parseIfInstruction();
        } else if (beginsWith(Instruction.WITH_KEYWORD)) {
            return parseWithInstruction();
        } else if (beginsWith(Instruction.TRY_KEYWORD)) {
            return parseTryInstruction();
        } else if (beginsWith("{")) {
            return parseInstructionGroup();
        } else if (beginsWith(IDENTIFIER)) {
            String name = consume(IDENTIFIER);
            Multiplicity m = parseMultiplicity();
            if (rules.containsKey(name) && procedures.containsKey(name)) {
                // ERROR: should never happen: ambiguous instruction (both rule and procedure).
            } else if (rules.containsKey(name)) {
                return new RuleInstruction(rules.get(name), m);
            } else if (procedures.containsKey(name)) {
                return procedures.get(name).instructions;
            } else if (BUILTIN_OPERATIONS.containsKey(name)) {
                // TODO: parse arguments and pass them to the runnable.
            }
        }
        return Instruction.NOOP;
    }

    private IfInstruction parseIfInstruction() {
        consume(Instruction.IF_KEYWORD);
        consumeWhitespace();
        consume("(");
        consumeWhitespace();
        ArrayList<Instruction> statement = parseInstructionList();
        consumeWhitespace();
        consume(")");
        Multiplicity m = parseMultiplicity();
        if (statement.size() > 3 || statement.size() < 2) {
            // ERROR: not allowed.
        }
        Instruction condition = statement.get(0);
        Instruction thenInstruction = statement.get(1);
        if (statement.size() == 3) {
            Instruction elseInstruction = statement.get(2);
            return new IfInstruction(condition, thenInstruction, elseInstruction, m);
        } else {
            return new IfInstruction(condition, thenInstruction, m);
        }
    }

    private WithInstruction parseWithInstruction() {
        consume(Instruction.WITH_KEYWORD);
        consumeWhitespace();
        consume("(");
        consumeWhitespace();
        ArrayList<Instruction> statement = parseInstructionList();
        consumeWhitespace();
        consume(")");
        Multiplicity m = parseMultiplicity();
        if (statement.size() > 3 || statement.size() < 2) {
            // ERROR: not allowed.
        }
        Instruction condition = statement.get(0);
        Instruction thenInstruction = statement.get(1);
        if (statement.size() == 3) {
            Instruction elseInstruction = statement.get(2);
            return new WithInstruction(condition, thenInstruction, elseInstruction, m);
        } else {
            return new WithInstruction(condition, thenInstruction, m);
        }
    }

    private TryInstruction parseTryInstruction() {
        consume(Instruction.TRY_KEYWORD);
        consumeWhitespace();
        consume("(");
        consumeWhitespace();
        Instruction i = parseInstruction();
        consumeWhitespace();
        consume(")");
        return new TryInstruction(i);
    }

    private InstructionGroup parseInstructionGroup() {
        consume("{");
        consumeWhitespace();
        ArrayList<Instruction> i = parseInstructionList();
        consumeWhitespace();
        consume("}");
        Multiplicity m = parseMultiplicity();
        return new InstructionGroup(i, m);
    }

    private InstructionSequence parseInstructionSequence() {
        ArrayList<Instruction> i = new ArrayList<Instruction>();
        consume("(");
        consumeWhitespace();
        i.add(parseInstruction());
        consumeWhitespace();
        while (!eof() && !beginsWith(")")) {
            i.add(parseInstruction());
            consumeWhitespace();
        }
        consumeOptionalComma();
        consume(")");
        Multiplicity m = parseMultiplicity();
        return new InstructionSequence(i, m);
    }

    private ArrayList<Instruction> parseInstructionList() {
        ArrayList<Instruction> list = new ArrayList<Instruction>();
        list.add(parseInstruction());
        consumeWhitespace();
        while (!eof() && !beginsWith("}")) {
            consume(",");
            consumeWhitespace();
            list.add(parseInstruction());
            consumeWhitespace();
        }
        consumeOptionalComma();
        return list;
    }

    private Multiplicity parseMultiplicity() {
        if (beginsWith("!")) {
            consume("!");
            return Multiplicity.WHILE_POSSIBLE;
        } else {
            if (beginsWith(";")) consume(";");
            return Multiplicity.ONCE;
        }
    }

    private void consumeOptionalComma() {
        if (beginsWith(",")) consume(",");
    }

}
