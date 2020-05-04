# frozen_string_literal: true

FlowCore::Pipeline.class_eval do
  def to_graph
    graph = GraphViz.new(name, type: :digraph, rankdir: "TB", splines: true, ratio: :auto)

    steps_mapping = {}
    steps.order(id: :asc).each do |s|
      sg = graph.add_nodes s.name, label: s.name, shape: :box, style: :filled
      steps_mapping[s.id] = sg
    end

    connections.each do |connection|
      graph.add_edges(
        steps_mapping.fetch(connection.from_step_id),
        steps_mapping.fetch(connection.to_step_id),
        weight: 1,
        arrowhead: :vee
      )
    end

    graph
  end

  def to_graph2
    graph = GraphViz.new(name, type: :digraph, rankdir: "TB", splines: true, ratio: :auto)

    steps_mapping = {}
    steps.order(id: :asc).each do |s|
      sg = graph.add_nodes s.name, label: s.name, shape: :box, style: :filled
      steps_mapping[s.id] = sg
    end

    connections.includes(:from_step).each do |connection|
      from_step = connection.from_step
      if from_step.appendable?
        add_graph = graph.add_nodes "append_to_#{from_step.id}",
                                    label: "+", shape: :circle, fixedsize: true, style: :filled,
                                    href: Rails.application.routes.url_helpers.new_pipeline_step_path(self, append_to_step_id: from_step.id)
        graph.add_edges(
          steps_mapping.fetch(connection.from_step_id),
          add_graph,
          weight: 1,
          arrowhead: :none
        )
        graph.add_edges(
          add_graph,
          steps_mapping.fetch(connection.to_step_id),
          weight: 1,
          arrowhead: :vee
        )
      else
        graph.add_edges(
          steps_mapping.fetch(connection.from_step_id),
          steps_mapping.fetch(connection.to_step_id),
          weight: 1,
          arrowhead: :vee
        )
      end
    end

    graph
  end
end
