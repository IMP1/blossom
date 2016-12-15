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
    private static final Pattern LITERAL_COLOUR = Pattern.compile("#\\w+");
    
    private static final Pattern ARROW          = Pattern.compile("<?\\->");

    private Graph graph;
    
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
        if (verbose) logger.push("Parsing Graph...");
        consumeWhitespace();
        if (eof()) {
            return graph;
        }
        consume("[");
        parseNodes();
        if (beginsWith("|")) {
            consume("|");
            parseEdges();
        }
        consume("]");
        if (verbose) logger.pop("Parsed Graph.");
        return graph;
    }
    
    private void parseNodes() {     
        if (verbose) logger.push("Parsing Nodes...");
        consumeWhitespace();
        if (eof() || beginsWith("|")) return;
        
        Node n;
        n = parseNode();
        graph.addNode(n);
        consumeWhitespace();
        
        while (!eof() && !beginsWith(Pattern.compile("(?:,\\s*)?\\|"))) {
            consume(",");
            consumeWhitespace();
            n = parseNode();
            graph.addNode(n);
            consumeWhitespace();
        }

        consumeWhitespace();
        consumeOptional(",");
        consumeWhitespace();
        if (verbose) logger.pop("Parsed Nodes.");
    }
    
    private Node parseNode() {
        if (verbose) logger.push("Parsing Node...");
        consumeWhitespace();
        String idString = consume(Pattern.compile("\\d+"));
        int id = Integer.parseInt(idString);
        consumeWhitespace();
        if (beginsWith("(")) {
            ArrayList<LabelItem> label = parseList();
            return new Node(id, label);
        }
        if (verbose) logger.pop("Parsed Node.");
        return new Node(id);
    }

    private void parseEdges() {
        if (verbose) logger.push("Parsing Edges...");
        consumeWhitespace();
        if (eof() || beginsWith("|")) return;
        
        Edge e;
        e = parseEdge();
        graph.addEdge(e);
        consumeWhitespace();
        
        while (!eof() && !beginsWith(Pattern.compile("(?:,\\s*)?\\]"))) {
            consume(",");
            consumeWhitespace();
            e = parseEdge();
            graph.addEdge(e);
            consumeWhitespace();
        }
        
        consumeWhitespace();
        consumeOptional(",");
        consumeWhitespace();
        if (verbose) logger.pop("Parsed Edges.");
    }
    
    private Edge parseEdge() {
        if (verbose) logger.push("Parsing Edge...");
        consumeWhitespace();
        int sourceId = Integer.parseInt(consume(Pattern.compile("\\d+")));
        consumeWhitespace();
        String direction = consume(ARROW);
        consumeWhitespace();
        int targetId = Integer.parseInt(consume(Pattern.compile("\\d+")));
        consumeWhitespace();

        if (beginsWith("(")) {
            ArrayList<LabelItem> label = parseList();
            if (direction == "<->") {
                graph.addEdge(new Edge(graph.getNode(targetId), graph.getNode(sourceId), label));
            }
            return new Edge(graph.getNode(sourceId), graph.getNode(targetId), label);
        }

        if (direction == "<->") {
            graph.addEdge(new Edge(graph.getNode(targetId), graph.getNode(sourceId)));
        }

        if (verbose) logger.pop("Parsed Edge.");
        return new Edge(graph.getNode(sourceId), graph.getNode(targetId));
    }
    
    private ArrayList<LabelItem> parseList() {
        if (verbose) logger.push("Parsing List...");
        ArrayList<LabelItem> list = new ArrayList<LabelItem>();
        consume("(");
        
        if (eof() || beginsWith(")")) return list;
        list.add(parseListItem());
        
        while (!eof() && !beginsWith(Pattern.compile("(?:,\\s*)?\\)"))) {
            consumeWhitespace();
            consume(",");
            consumeWhitespace();
            
            list.add(parseListItem());
            if (verbose) logger.log("Added Item to List.");
        }
        
        consumeWhitespace();
        consumeOptional(",");
        consumeWhitespace();
        consume(")");

        if (verbose) logger.pop("Parsed List.");
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
        	throw new InvalidSyntaxException("Invalid list literal");
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

}
