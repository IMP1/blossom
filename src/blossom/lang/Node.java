package blossom.lang;

import java.util.ArrayList;

public class Node {

    public final int id;
    private ArrayList<String> label;
    
    public Node(int id, ArrayList<String> label) {
        this.id = id;
        this.label = label;
    }
    
    public Node(int id) {
        this(id, new ArrayList<String>());
    }
    
}
