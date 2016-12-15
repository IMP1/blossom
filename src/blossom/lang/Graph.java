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

    //------------------------------------------
    // Graph Transformation Methods
    //------------------------------------------

    public Graph removeNode(int id) {
        return removeNode(getNode(id));
    }

    public Graph removeNode(Node n) {
        // Dangling Edges
        if (Functions.in(this, n) > 0)  return INVALID;
        if (Functions.out(this, n) > 0) return INVALID;
        if (!nodes.containsKey(n.id))   return INVALID;
        nodes.remove(n.id);
        return this;
    }

    public Graph removeEdge(int sourceId, int targetId) {
        return removeEdge(getNode(sourceId), getNode(targetId));
    }

    public Graph removeEdge(Node source, Node target) {
        Edge edge = null;
        for (Edge e : edges) {
            if (e.source == source && e.target == target) {
                edge = e;
            }
        }
        if (edge == null) return INVALID;
        edges.remove(edge);
        return this;
    }

    public Graph removedEdge(Edge e) {
        edges.remove(e);
        return this;
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
    
    public String toStringCondensed() {
    	StringBuilder text = new StringBuilder();
        text.append("[ ");
        for (int n : nodes.keySet()) {
            text.append(n);
            text.append(", ");
        }
        text.append("| ");
        for (Edge e : edges) {
            text.append(e.source.id);
            text.append("->");
            text.append(e.target.id);
            text.append(", ");
        }
        text.append("]");
        return text.toString();
    }
    
}
