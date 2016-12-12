package blossom.lang;

import java.util.ArrayList;
import java.util.HashMap;

public class Graph {

    public static final String DEFINITION_KEYWORD = "graph";

    public static final Graph INVALID = null;
    
    private HashMap<Integer, Node> nodes;
    private ArrayList<Edge> edges;
    
    public Graph(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        this.edges = edges;
        this.nodes = new HashMap<Integer, Node>();
        for (Node n : nodes) {
            addNode(n);
        }
    }
    
    public Graph() {
        this.nodes = new HashMap<Integer, Node>();
        this.edges = new ArrayList<Edge>();
    }
    
    public void addNode(Node n) {
        if (nodes.containsKey(n.id)) {
            System.err.printf("[Warning] There is already a node with id %d.\n", n.id);
        }
        nodes.put(n.id, n);
    }

    public void addEdge(Edge e) {
        edges.add(e);
    }
    
    public void addEdge(int source, int target) {
        Edge e = new Edge(getNode(source), getNode(target));
        addEdge(e);
    }

    public Node getNode(int nodeId) {
        return nodes.get(nodeId);
    }

    public Node[] nodes() {
        return nodes.values().toArray(new Node[nodes.size()]);
    }

    public Edge[] edges() {
        return edges.toArray(new Edge[edges.size()]);
    }

    @Override
    public String toString() {
        StringBuilder text = new StringBuilder();
        text.append("[\n");
        for (Node n : nodes.values()) {
            text.append("\t");
            text.append(n);
            text.append("\n");
        }
        text.append("|\n");
        for (Edge e : edges) {
            text.append("\t");
            text.append(e);
            text.append("\n");
        }
        text.append("]");
        return text.toString();
    }
    
}
