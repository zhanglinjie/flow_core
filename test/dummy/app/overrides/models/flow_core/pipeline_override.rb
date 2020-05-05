# frozen_string_literal: true

FlowCore::Pipeline.class_eval do
  def to_graphviz(interactive: true)
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :spline, ratio: :auto)

    start_step = steps.find_by type: "FlowCore::Steps::Start"
    return graph unless start_step

    start_step.append_to_graphviz(graph, interactive: interactive)

    graph
  end
end
