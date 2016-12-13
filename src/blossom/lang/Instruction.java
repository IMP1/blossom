package blossom.lang;

import java.util.ArrayList;

public abstract class Instruction {

    public static final String IF_KEYWORD   = "if";
    public static final String WITH_KEYWORD = "with";
    public static final String TRY_KEYWORD  = "try";

    public enum Multiplicity {
        ONCE,
        OPTIONAL,
        WHILE_POSSIBLE
    }

    public final Multiplicity multiplicity;

    public Instruction() {

    }

    public abstract Graph execute(final Graph g);
    
}
