package blossom.lang;

public class LabelItem<T> {
    
    public enum Type {
        ANY,
        INTEGER,
        STRING,
        BOOLEAN,
    }

    public T value;

    public LabelItem(T value) {
        this.value = value;
    }

}