# frozen_string_literal: true

FlowCore::Pipeline.class_eval do
  def to_designer_graphviz
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :spline, ratio: :auto)

    steps.each do |step|
      step.graphviz_node(graph, interactive: true)
    end

    start_step&.append_to_designer_graphviz(graph)

    graph
  end

  def to_graphviz
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :spline, ratio: :auto)

    steps.each do |step|
      step.graphviz_node(graph)
    end

    start_step&.append_to_graphviz(graph)

    graph
  end
end
