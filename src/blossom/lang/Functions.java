package blossom.lang;

public class Functions {

    public static int in(Graph graph, int nodeId) {
        int count = 0;
        Node target = graph.getNode(nodeId);
        for (Edge e : graph.edges()) {
            if (e.target == target) {
                count ++;
            }
        }
        return count;
    }

    public static int out(Graph graph, int nodeId) {
        int count = 0;
        Node source = graph.getNode(nodeId);
        for (Edge e : graph.edges()) {
            if (e.source == source) {
                count ++;
            }
        }
        return count;
    }

    public static boolean edge(Graph graph, int sourceId, int targetId) {
        Node source = graph.getNode(sourceId);
        Node target = graph.getNode(targetId);
        for (Edge e : graph.edges()) {
            if (e.source == source && e.target == target) {
                return true;
            }
        }
        return false;
    }

    public static boolean uedge(Graph graph, int node1Id, int node2Id) {
        Node node1 = graph.getNode(node1Id);
        Node node2 = graph.getNode(node2Id);
        for (Edge e : graph.edges()) {
            if ((e.source == node1 && e.target == node2) || (e.source == node2 && e.target == node1)) {
                return true;
            }
        }
        return false;
    }
    
}
