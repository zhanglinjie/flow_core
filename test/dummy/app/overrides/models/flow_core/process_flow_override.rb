# frozen_string_literal: true

FlowCore::ProcessFlow.class_eval do
  def to_graph
    graph = GraphViz.new(name, type: :digraph, rankdir: "TB", splines: true, ratio: :auto)

    steps_mapping = {}
    steps.order(id: :asc).each do |s|
      sg = graph.add_nodes s.name, label: s.name, shape: :box, style: :filled
      steps_mapping[s.id] = sg
    end

    connections.each do |connection|
      graph.add_edges(
        steps_mapping.fetch(connection.source_id),
        steps_mapping.fetch(connection.destination_id),
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

    connections.includes(:source).each do |connection|
      source = connection.source
      if source.appendable?
        add_graph = graph.add_nodes "append_to_#{source.id}",
                                    label: "+", shape: :circle, fixedsize: true, style: :filled,
                                    href: Rails.application.routes.url_helpers.new_process_flow_step_path(self, append_to_id: source.id)
        graph.add_edges(
          steps_mapping.fetch(connection.source_id),
          add_graph,
          weight: 1,
          arrowhead: :none
        )
        graph.add_edges(
          add_graph,
          steps_mapping.fetch(connection.destination_id),
          weight: 1,
          arrowhead: :vee
        )
      else
        graph.add_edges(
          steps_mapping.fetch(connection.source_id),
          steps_mapping.fetch(connection.destination_id),
          weight: 1,
          arrowhead: :vee
        )
      end
    end

    graph
  end
end
