package blossom.lang;

import java.util.ArrayList;

public class Node {

    public final int id;
    private ArrayList<LabelItem> label;
    
    public Node(int id, ArrayList<LabelItem> label) {
        this.id = id;
        this.label = label;
    }
    
    public Node(int id) {
        this(id, new ArrayList<LabelItem>());
    }
    
}
