package blossom.compiler;

import blossom.lang.Graph;
import blossom.lang.Node;
import blossom.lang.Rule.Variable;
import blossom.lang.LabelItem;
import blossom.lang.LabelVariable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;

import blossom.lang.Edge;

public class GraphParser extends Parser {

    private static final Pattern LITERAL_INT    = Pattern.compile("-?\\d+");
    private static final Pattern LITERAL_STRING = Pattern.compile("\".+?(<!\\\\)\"");
    private static final Pattern LITERAL_COLOUR = Pattern.compile("#\\w+?");

    private Graph graph;
    private ArrayList<Node> nodes;
    private ArrayList<Edge> edges;
    
    private HashMap<String, LabelItem.Type> variables;

    public GraphParser(String graphCode) {
        this(graphCode, null);
    }
    
    public GraphParser(String graphCode, ArrayList<Variable> variableList) {
        super(graphCode);
        graph = new Graph();

        variables = new HashMap<String, LabelItem.Type>();
        if (variableList != null) {
            for (Variable v : variableList) {
                variables.put(v.name, v.type);
            }
        }
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
            ArrayList<LabelItem> label = parseList();
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
            ArrayList<LabelItem> label = parseList();
            return new Edge(nodes.get(sourceId), nodes.get(targetId), label);
        }
        return new Edge(nodes.get(sourceId), nodes.get(targetId));
    }
    
    private ArrayList<LabelItem> parseList() {
        ArrayList<LabelItem> list = new ArrayList<LabelItem>();
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
    
    private LabelItem parseListItem() {
        if (beginsWith("\"")) {
            return new LabelItem(LabelItem.Type.STRING, parseString());
        } else if (beginsWith("#")) {
            return new LabelItem(LabelItem.Type.COLOUR, parseColour());
        } else if (beginsWith(Pattern.compile("\\d"))) {
            return new LabelItem(LabelItem.Type.INTEGER, parseInt());
        } else if (variables != null) {
            String variableName = parseVariable();
            return new LabelVariable(variables.get(variableName), variableName);
        } else {
        	throw new InvalidSyntaxException("Invalid variable literal");
        }
    }
    
    private String parseInt() {
        return consume(LITERAL_INT);
    }
    
    private String parseString() {
        return consume(LITERAL_STRING);
    }
    
    private String parseColour() {
        return consume(LITERAL_COLOUR);
    }
    
    private String parseVariable() {
        return consume(ProgramParser.IDENTIFIER);
    }
    
    private void consumeOptionalComma() {
        if (beginsWith(",")) consume(",");
    }
    
}
