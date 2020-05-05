# frozen_string_literal: true

FlowCore::Step.class_eval do
  def append_to_graphviz(graph, interactive:)
    if containable?
      return append_children_to_graphviz(graph, interactive: interactive)
    end

    current_node = graphviz_node(graph)
    graph << current_node unless graph.nodes[graphviz_node_key]

    return current_node if current_node.connections.any?

    if interactive && appendable?
      append_to_current_node =
        Graphviz::Node.new append_to_node_key,
                           label: "+", shape: :circle, fixedsize: true, style: :filled, fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)
      graph << append_to_current_node

      return append_to_current_node if current_node.connected?(append_to_node_key)

      current_node.connect append_to_current_node

      last_node = append_to_current_node
    else
      last_node = current_node
    end

    if to_step
      next_node = to_step.graphviz_node(graph)
      graph << next_node unless graph.nodes[to_step.graphviz_node_key]

      return last_node if last_node.connected? next_node

      last_node.connect next_node, weight: (next_node.connections.any? ? 0 : 10)

      to_step.append_to_graphviz(graph, interactive: interactive)
    else
      last_node
    end
  end

  def append_children_to_graphviz(graph, interactive:)
    current_node = graphviz_node(graph)
    graph << current_node unless graph.nodes[graphviz_node_key]

    return current_node if current_node.connections.any?

    if containing_steps.empty?
      if interactive
        add_to_current_node =
          Graphviz::Node.new add_to_node_key,
                             label: "+", shape: :circle, fixedsize: true, style: :filled, fillcolor: :white,
                             href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, add_to_container_step_id: id)
        graph << add_to_current_node

        append_to_current_node =
          Graphviz::Node.new append_to_node_key,
                             label: "+", shape: :circle, fixedsize: true, style: :filled, fillcolor: :white,
                             href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)
        graph << append_to_current_node

        current_node.connect add_to_current_node
        add_to_current_node.connect append_to_current_node, style: :dashed

        last_node = append_to_current_node
      else
        last_node = current_node
      end

      if to_step
        next_node = to_step&.graphviz_node(graph)
        graph << next_node if next_node

        return last_node if last_node.connected? next_node

        last_node.connect next_node

        return to_step.append_to_graphviz(graph, interactive: interactive)
      else
        return last_node
      end
    end

    if interactive
      add_to_current_node =
        Graphviz::Node.new add_to_node_key,
                           label: "+", shape: :circle, fixedsize: true, style: :filled, fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, add_to_container_step_id: id)
      graph << add_to_current_node

      append_to_current_node =
        Graphviz::Node.new append_to_node_key,
                           label: "+", shape: :circle, fixedsize: true, style: :filled, fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)
      graph << append_to_current_node

      current_node.connect add_to_current_node
      add_to_current_node.connect append_to_current_node, style: :dashed

      containing_steps.each do |child_step|
        child_node = child_step.graphviz_node(graph)
        graph << child_node

        current_node.connect child_node

        last_node = child_step.append_to_graphviz(graph, interactive: interactive)
        last_node.connect append_to_current_node, style: :dashed if last_node.connections.empty?
      end

      return append_to_current_node unless to_step

      next_node = to_step.graphviz_node(graph)
      graph << next_node

      append_to_current_node.connect next_node
    else
      next_node = to_step&.graphviz_node(graph)
      graph << next_node if next_node

      containing_steps.each do |child_step|
        child_node = child_step.graphviz_node(graph)
        graph << child_node

        current_node.connect child_node

        last_node = child_step.append_to_graphviz(graph, interactive: interactive)
        last_node.connect next_node, style: :dashed if next_node && last_node.connections.empty?
      end
    end

    to_step&.append_to_graphviz(graph, interactive: interactive)
  end

  def graphviz_node_key
    "step_#{id}"
  end

  def append_to_node_key
    "append_to_#{graphviz_node_key}"
  end

  def add_to_node_key
    "add_to_#{graphviz_node_key}"
  end

  def graphviz_node(graph)
    if graph.nodes[graphviz_node_key]
      return graph.nodes[graphviz_node_key]
    end

    shape = containable? ? :diamond : :box
    Graphviz::Node.new(graphviz_node_key, graph, label: name, shape: shape, style: :filled, fillcolor: :white)
  end
end
