class Tracer

    DEFAULT_DIRECTORY = "trace"
    OVERVIEW_FILENAME = "_overview.trace"

    def initialize(tracing_directory=nil)
        tracing_directory ||= DEFAULT_DIRECTORY
        @tracing_directory = tracing_directory
        @saved_graph_count = 0

        # TODO: create directory and empty overview file.
    end

    def save_graph(graph)
        append("[Graph]")
        filename = File.join(@tracing_directory, "graph_#{@saved_graph_count}")
        File.open(filename, 'w') do |file|
            file.puts(graph.to_s)
        end
        @saved_graph_count += 1
    end

    def append(action)
        filename = File.join(@tracing_directory, OVERVIEW_FILENAME)
        File.open(filename, 'a') do |file|
            file.puts(action)
        end
    end

end