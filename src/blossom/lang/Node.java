package blossom.lang;

public class Node {

    public final int id;
    private Label label;
    
    public Node(int id, Label label) {
        this.id = id;
        this.label = label;
    }
    
    public Node(int id) {
        this(id, null);
    }
    
    public Label label() {
        return label;
    }
    
}
