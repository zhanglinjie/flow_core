# frozen_string_literal: true

FlowCore::Pipeline.class_eval do
  def to_graphviz(interactive: true)
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :spline, ratio: :auto)

    steps.each do |step|
      step.graphviz_node(graph)
    end

    start_step&.append_to_graphviz(graph, interactive: interactive)

    graph
  end
end
