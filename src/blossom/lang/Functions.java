package blossom.lang;

public class Functions {

    public static int in(Graph graph, int nodeId) {
        int count = 0;
        Node target = graph.nodes.get(nodeId);
        for (Edge e : graph.edges) {
            if (e.target == target) {
                count ++;
            }
        }
        return count;
    }

    public static int out(Graph graph, int nodeId) {
        int count = 0;
        Node source = graph.nodes.get(nodeId);
        for (Edge e : graph.edges) {
            if (e.source == source) {
                count ++;
            }
        }
        return count;
    }

    public static boolean edge(Graph graph, int sourceId, int targetId) {
        Node source = graph.nodes.get(sourceId);
        Node target = graph.nodes.get(targetId);
        for (Edge e : graph.edges) {
            if (e.source == source && e.target == target) {
                return true;
            }
        }
        return false;
    }

    public static boolean uedge(Graph graph, int node1Id, int node2Id) {
        Node source = graph.nodes.get(sourceId);
        Node target = graph.nodes.get(targetId);
        for (Edge e : graph.edges) {
            if ((e.source == source && e.target == target) || (e.source == target && e.target == source)) {
                return true;
            }
        }
        return false;
    }
    
}
