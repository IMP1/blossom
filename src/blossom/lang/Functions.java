package blossom.lang;

public class Functions {

    public static int in(Graph graph, int nodeId) {
        return in(graph, graph.getNode(nodeId));
    }

    public static int in(Graph graph, Node target) {
        int count = 0;
        for (Edge e : graph.edges()) {
            if (e.target == target) {
                count ++;
            }
        }
        return count;
    }

    public static int out(Graph graph, int nodeId) {
        return out(graph, graph.getNode(nodeId));
    }

    public static int out(Graph graph, Node source) {
        int count = 0;
        for (Edge e : graph.edges()) {
            if (e.source == source) {
                count ++;
            }
        }
        return count;
    }

    public static boolean edge(Graph graph, int sourceId, int targetId) {
        return edge(graph, graph.getNode(sourceId), graph.getNode(targetId));
    }

    public static boolean edge(Graph graph, Node source, Node target) {
        for (Edge e : graph.edges()) {
            if (e.source == source && e.target == target) {
                return true;
            }
        }
        return false;
    }

    public static boolean uedge(Graph graph, int node1Id, int node2Id) {
        return edge(graph, graph.getNode(node1Id), graph.getNode(node2Id));
    }

    public static boolean uedge(Graph graph, Node node1, Node node2) {
        for (Edge e : graph.edges()) {
            if ((e.source == node1 && e.target == node2) || (e.source == node2 && e.target == node1)) {
                return true;
            }
        }
        return false;
    }
    
}
