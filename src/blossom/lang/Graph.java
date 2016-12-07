package blossom.lang;

import java.util.ArrayList;

public class Graph {
	
	ArrayList<Node> nodes;
	ArrayList<Edge> edges;
	
	public Graph(ArrayList<Node> nodes, ArrayList<Edge> edges) {
		this.nodes = nodes;
		this.edges = edges;
	}
	
	public Graph() {
		this.nodes = new ArrayList<Node>();
		this.edges = new ArrayList<Edge>();
	}
	
	public void addNode(Node n) {
		nodes.add(n);
	}
	
	public void addEdge(Edge e) {
		edges.add(e);
	}
	
	public void addEdge(int source, int target) {
		Edge e = new Edge(nodes.get(source), nodes.get(target));
		addEdge(e);
	}
	
	@Override
	public String toString() {
		StringBuilder text = new StringBuilder();
		text.append("[\n");
		for (Node n : nodes) {
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
