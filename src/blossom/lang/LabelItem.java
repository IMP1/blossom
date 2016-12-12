package blossom.lang;

public class LabelItem {
    
    public enum Type {
        ANY,
        INTEGER,
        STRING,
        COLOUR,
    }

    public final Type    type;
    public final String  value;

    public LabelItem(Type type, String value) {
        this.type       = type;
        this.value      = value;
    }

}