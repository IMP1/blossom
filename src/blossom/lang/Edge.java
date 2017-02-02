package blossom.lang;

public class Edge {

    public final Node source;
    public final Node target;
    private Label label;
    
    public Edge(Node source, Node target, Label label) {
        this.source = source;
        this.target = target;
        this.label  = label;
    }
    
    public Edge(Node source, Node target) {
        this(source, target, null);
    }
    
}
