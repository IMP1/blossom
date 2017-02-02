package blossom.compiler;

import blossom.lang.Graph;
import blossom.lang.Label;
import blossom.lang.Node;
import blossom.lang.Rule.Variable;
import blossom.lang.LabelItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Pattern;

import blossom.lang.Edge;

public class GraphParser extends Parser {

    private static final Pattern LITERAL_INT    = Pattern.compile("-?\\d+");
    private static final Pattern LITERAL_STRING = Pattern.compile("\".+?(<!\\\\)\"");
    private static final Pattern LITERAL_BOOL   = Pattern.compile("(?:TRUE|FALSE|T|F)");
    
    private static final Pattern LABEL_MARK     = Pattern.compile("#\\w+");
    
    private static final Pattern ARROW          = Pattern.compile("\\->");

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
            Label label = parseLabel();
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
        consume(ARROW);
        consumeWhitespace();
        int targetId = Integer.parseInt(consume(Pattern.compile("\\d+")));
        consumeWhitespace();

        if (beginsWith("(")) {
            Label label = parseLabel();
            return new Edge(graph.getNode(sourceId), graph.getNode(targetId), label);
        }

        if (verbose) logger.pop("Parsed Edge.");
        return new Edge(graph.getNode(sourceId), graph.getNode(targetId));
    }
    
    private Label parseLabel() {
        if (verbose) logger.push("Parsing Label...");
        consume("(");
        
        if (eof() || beginsWith(")")) return null;
        
        LabelItem<?> labelValue = parseLabelValue();
        ArrayList<String> marks = new ArrayList<String>();
        
        while (!eof() && !beginsWith(Pattern.compile(",?\\s*\\)"))) {
            consumeWhitespace();
            consume(",");
            consumeWhitespace();
            
            marks.add(parseMark());
            if (verbose) logger.log("Added Item to List.");
        }
        
        consumeWhitespace();
        consumeOptional(",");
        consumeWhitespace();
        consume(")");

        if (verbose) logger.pop("Parsed List.");
        return new Label(labelValue, marks);
    }
    
    private LabelItem<?> parseLabelValue() {
        if (beginsWith("\"")) {
            return new LabelItem<String>(parseString());
        } else if (beginsWith(LITERAL_INT)) {
            return new LabelItem<Integer>(parseInt());
        } else if (beginsWith(LITERAL_BOOL)) {
            return new LabelItem<Boolean>(parseBool());
        } else {
        	return null;
        }
    }
    
    private int parseInt() {
        return Integer.parseInt(consume(LITERAL_INT));
    }
    
    private String parseString() {
        return consume(LITERAL_STRING);
    }
    
    private Boolean parseBool() {
        String bool = consume(LITERAL_BOOL);
        return bool.toUpperCase().startsWith("T");
    }
    
    private String parseMark() {
        return consume(LABEL_MARK);
    }
    
}
