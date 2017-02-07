package blossom.compiler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;

import blossom.lang.*;
import blossom.lang.instruction.*;
import blossom.lang.instruction.Instruction.Multiplicity;
import blossom.lang.Rule.Variable;

public class InstructionParser extends Parser {

    private HashMap<String, Rule> rules;
    private HashMap<String, Procedure> procedures;

    public InstructionParser(String graphCode, HashMap<String, Rule> rules, HashMap<String, Procedure> procedures) {
        super(graphCode);
        this.rules = rules;
        this.procedures = procedures;
    }

    public Instruction parse() {
        if (verbose) logger.push("Parsing Instruction...");
        Instruction instruction = Instruction.NOOP;
        if (beginsWith("//")) {
            consumeRestOfLine();
        } else if (beginsWith(Instruction.NOOP_KEYWORD)) {
            consume(Instruction.NOOP_KEYWORD);
            parseMultiplicity();
        } else if (beginsWith(Instruction.INVALID_KEYWORD)) {
            consume(Instruction.INVALID_KEYWORD);
            Multiplicity m = parseMultiplicity();
            if (m != Multiplicity.WHILE_POSSIBLE) {
                instruction = Instruction.INVALID;
            }
        } else if (beginsWith(Instruction.IF_KEYWORD)) {
            instruction = parseIfInstruction();
        } else if (beginsWith(Instruction.WITH_KEYWORD)) {
            instruction = parseWithInstruction();
        } else if (beginsWith(Instruction.TRY_KEYWORD)) {
            instruction = parseTryInstruction();
        } else if (beginsWith("{")) {
            instruction = parseInstructionGroup();
        } else if (beginsWith("(")) {
            instruction = parseInstructionSequence();
        } else if (beginsWith(ProgramParser.IDENTIFIER)) {
            String name = consume(ProgramParser.IDENTIFIER);
            Multiplicity m = parseMultiplicity();
            if (rules.containsKey(name) && procedures.containsKey(name)) {
                // ERROR: should never happen: ambiguous instruction (both rule and procedure).
                logger.log("ERROR: Ambiguous instruction: Both a rule and a procedure are called " + name + ".");
            } else if (rules.containsKey(name)) {
                instruction = new RuleInstruction(rules.get(name), m);
            } else if (procedures.containsKey(name)) {
                instruction = procedures.get(name).instructions;
            }
        }
        if (verbose) logger.push("Parsed Instruction.");
        return instruction;
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
            logger.log("ERROR: Invalid amount of parameters to an if statement.");
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
            logger.log("ERROR: Invalid amount of parameters to a with statement.");
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
        while (!eof() && !beginsWith(Pattern.compile("(?:,\\s*)?)"))) {
            i.add(parseInstruction());
            consumeWhitespace();
        }
        consumeOptional(",");
        consume(")");
        Multiplicity m = parseMultiplicity();
        return new InstructionSequence(i, m);
    }

    private ArrayList<Instruction> parseInstructionList() {
        ArrayList<Instruction> list = new ArrayList<Instruction>();
        list.add(parseInstruction());
        consumeWhitespace();
        while (!eof() && beginsWith(ProgramParser.IDENTIFIER)) {
            consume(",");
            consumeWhitespace();
            list.add(parseInstruction());
            consumeWhitespace();
        }
        consumeOptional(",");
        return list;
    }

    private Multiplicity parseMultiplicity() {
        if (verbose) logger.log("Parsing Multiplicity...");
        if (beginsWith("!")) {
            consume("!");
            return Multiplicity.WHILE_POSSIBLE;
        } else {
            consumeOptional(";");
            return Multiplicity.ONCE;
        }
    }

}