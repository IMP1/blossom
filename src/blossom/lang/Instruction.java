package blossom.lang;

public abstract class Instruction {

    public static final String IF_KEYWORD   = "if";
    public static final String WITH_KEYWORD = "with";
    public static final String TRY_KEYWORD  = "try";

    

    public final 

    public Instruction() {

    }

    public abstract Graph execute(Graph g);
    
}
