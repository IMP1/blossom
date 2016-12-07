package blossom.lang;

import java.util.ArrayList;

public class Edge {

	private Node source;
	private Node target;
	private ArrayList<String> label;
	
	public Edge(Node source, Node target, ArrayList<String> label) {
		this.source = source;
		this.target = target;
		this.label = label;
	}
	
	public Edge(Node source, Node target) {
		this(source, target, new ArrayList<String>());
	}
	
}
