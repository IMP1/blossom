package blossom.compiler;

import blossom.lang.Graph;
import blossom.lang.Node;

import java.util.ArrayList;
import java.util.regex.Pattern;

import blossom.lang.Edge;

public class GraphParser extends Parser {
    
    private Graph graph;
    private ArrayList<Node> nodes;
    private ArrayList<Edge> edges;
    
    private boolean acceptsVariables;
    
    public GraphParser(String graphCode, boolean acceptsVariables) {
        super(graphCode);
        graph = new Graph();
        this.acceptsVariables = acceptsVariables;
    }

    public Graph parse() {
        consumeWhitespace();
        if (eof()) {
            return graph;
        }
        consume("[");
        parseNodes();
        consume("|");
        parseEdges();
        consume("]");
        return graph;
    }
    
    private void parseNodes() {     
        consumeWhitespace();
        if (eof() || beginsWith("|")) return;
        
        Node n;
        n = parseNode();
        graph.addNode(n);
        
        while (!eof() && !beginsWith("|")) {
            consumeWhitespace();
            consume(",");
            consumeWhitespace();
            n = parseNode();
            graph.addNode(n);
        }
        
        consumeWhitespace();
        consumeOptionalComma();
        consumeWhitespace();
    }
    
    private Node parseNode() {
        consumeWhitespace();
        String idString = consume(Pattern.compile("\\d+"));
        System.out.printf("'%s'\n", idString);
        int id = Integer.parseInt(idString);
        consumeWhitespace();
        if (beginsWith("(")) {
            ArrayList<String> label = parseList();
            return new Node(id, label);
        }
        return new Node(id);
    }

    private void parseEdges() {
        while (!eof() && !beginsWith("]")) {
            Edge e = parseEdge();
            graph.addEdge(e);
        }
    }
    
    private Edge parseEdge() {
        int sourceId = Integer.parseInt(consume(Pattern.compile("\\d+")));
        consumeWhitespace();
        String direction = consume(Pattern.compile("[<->|->]"));
        consumeWhitespace();
        int targetId = Integer.parseInt(consume(Pattern.compile("\\d+")));
        consumeWhitespace();
        if (beginsWith("(")) {
            ArrayList<String> label = parseList();
            return new Edge(nodes.get(sourceId), nodes.get(targetId), label);
        }
        return new Edge(nodes.get(sourceId), nodes.get(targetId));
    }
    
    private ArrayList<String> parseList() {
        ArrayList<String> list = new ArrayList<String>();
        consume("(");
        
        if (!eof() || beginsWith(")")) return list;
        list.add(parseListItem());
        
        while (!eof() && !beginsWith(")")) {
            consumeWhitespace();
            consume(",");
            consumeWhitespace();
            
            list.add(parseListItem());
        }
        
        consumeWhitespace();
        consumeOptionalComma();
        consumeWhitespace();
        
        consume(")");
        return list;
    }
    
    private String parseListItem() {
        if (beginsWith("\"")) {
            return parseString();
        } else if (beginsWith("#")) {
            return parseColour();
        } else if (beginsWith(Pattern.compile("\\d"))) {
            return parseInt();
        } else if (acceptsVariables) {
            return parseVariable();
        } else {
        	throw new InvalidSyntaxException("Invalid variable literal");
        }
    }
    
    private String parseInt() {
        return consume(Pattern.compile("\\d+"));
    }
    
    private String parseString() {
        return consume(Pattern.compile("\".+?(<!\\\\)\""));
    }
    
    private String parseColour() {
        return consume(Pattern.compile("#\\w+?"));
    }
    
    private String parseVariable() {
        return ""; // TODO: parse Variables.
    }
    
    private void consumeOptionalComma() {
        if (beginsWith(",")) consume(",");
    }
    
}
