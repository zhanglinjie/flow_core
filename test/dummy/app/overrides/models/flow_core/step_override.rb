# frozen_string_literal: true

FlowCore::Step.class_eval do
  def append_to_designer_graphviz(graph)
    if multi_branch?
      return append_multi_branch_step_to_designer_graphviz(graph)
    end

    current_node = graphviz_node(graph, interactive: true)
    return current_node if current_node.connections.any?

    if appendable?
      append_to_current_node =
        Graphviz::Node.new append_to_node_key, graph,
                           label: "+ Task", shape: :box, style: "dashed, filled", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)

      return append_to_current_node if current_node.connected?(append_to_node_key)

      current_node.connect append_to_current_node, arrowhead: :none

      last_node = append_to_current_node
    end

    if to_step
      next_node = to_step.graphviz_node(graph, interactive: true)

      return last_node if last_node.connected? next_node

      last_node.connect next_node, weight: (next_node.connections.any? ? 0 : 10),
                                   href: Rails.application.routes.url_helpers.edit_pipeline_connection_path(pipeline, to_connection)

      to_step.append_to_designer_graphviz(graph)
    else
      last_node
    end
  end

  def append_multi_branch_step_to_designer_graphviz(graph)
    current_node = graphviz_node(graph, interactive: true)
    return current_node if current_node.connections.any?

    if branches.empty?
      add_to_current_node =
        Graphviz::Node.new add_to_node_key, graph,
                           label: "+ Branch", shape: :oval, style: "dashed, filled", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_branch_path(pipeline, self)

      append_to_current_node =
        Graphviz::Node.new append_to_node_key, graph,
                           label: "+ Task", shape: :box, style: "dashed, filled", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)

      current_node.connect add_to_current_node, arrowhead: :none
      add_to_current_node.connect append_to_current_node

      if to_step
        next_node = to_step&.graphviz_node(graph, interactive: true)

        return append_to_current_node if append_to_current_node.connected? next_node

        append_to_current_node.connect next_node, arrowhead: :none

        return to_step.append_to_designer_graphviz(graph)
      else
        return append_to_current_node
      end
    end

    add_to_current_node =
      Graphviz::Node.new add_to_node_key, graph,
                         label: "+ Branch", shape: :oval, style: "dashed, filled", fillcolor: :white,
                         href: Rails.application.routes.url_helpers.new_pipeline_step_branch_path(pipeline, self)

    append_to_current_node =
      Graphviz::Node.new append_to_node_key, graph,
                         label: "+ Task", shape: :box, style: "dashed, filled", fillcolor: :white,
                         href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)

    current_node.connect add_to_current_node, arrowhead: :none, style: :dashed
    add_to_current_node.connect append_to_current_node, style: :dashed

    branches.each do |branch|
      branch_node_key = "step_#{id}_branch_#{branch.id}"
      branch_node =
        Graphviz::Node.new branch_node_key, graph,
                           label: branch.name, shape: :oval, style: :filled, fillcolor: :white,
                           href: Rails.application.routes.url_helpers.edit_pipeline_step_branch_path(pipeline, self, branch)

      append_to_branch_node_key = "append_to_step_#{id}_branch_#{branch.id}"
      append_to_branch_node =
        Graphviz::Node.new append_to_branch_node_key, graph,
                           label: "+ Task", shape: :box, style: "dashed, filled", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_branch_id: branch.id)

      current_node.connect branch_node, arrowhead: :none

      child_step = branch.step
      if child_step && child_step != to_step
        branch_node.connect append_to_branch_node, arrowhead: :none
        child_node = child_step.graphviz_node(graph, interactive: true)
        append_to_branch_node.connect child_node
        last_node = child_step.append_to_designer_graphviz(graph)
        if last_node.connections.empty?
          last_node.connect append_to_current_node, style: :dashed, label: "Implicit connect",
                                                    href: Rails.application.routes.url_helpers.new_pipeline_connection_path(pipeline, from_step_id: child_step.id)
        end
      elsif child_step == to_step
        branch_node.connect append_to_branch_node, arrowhead: :none
        append_to_branch_node.connect append_to_current_node
      else
        branch_node.connect append_to_branch_node, style: :dashed, arrowhead: :none
        append_to_branch_node.connect append_to_current_node, style: :dashed
      end
    end

    return append_to_current_node unless to_step

    next_node = to_step.graphviz_node(graph, interactive: true)

    append_to_current_node.connect next_node

    to_step&.append_to_designer_graphviz(graph)
  end

  def append_to_graphviz(graph)
    if multi_branch?
      return append_multi_branch_step_to_graphviz(graph)
    end

    current_node = graphviz_node(graph)
    return current_node if current_node.connections.any?

    if to_step
      next_node = to_step.graphviz_node(graph)

      return current_node if current_node.connected? next_node

      current_node.connect next_node, weight: (next_node.connections.any? ? 0 : 10)

      to_step.append_to_graphviz(graph)
    else
      current_node
    end
  end

  def append_multi_branch_step_to_graphviz(graph)
    current_node = graphviz_node(graph)
    return current_node if current_node.connections.any?

    if branches.empty?
      if to_step
        next_node = to_step&.graphviz_node(graph)

        return current_node if current_node.connected? next_node

        current_node.connect next_node, arrowhead: :none

        return to_step.append_to_graphviz(graph)
      else
        return current_node
      end
    end

    next_node = to_step&.graphviz_node(graph)

    branches.each do |branch|
      branch_node_key = "step_#{id}_branch_#{branch.id}"
      branch_node =
        Graphviz::Node.new branch_node_key, graph,
                           label: branch.name, shape: :oval, style: :filled, fillcolor: :white

      current_node.connect branch_node, arrowhead: :none

      child_step = branch.step
      if child_step
        branch_node.connect child_step.graphviz_node(graph)
        if child_step != to_step
          last_node = child_step.append_to_graphviz(graph)
          last_node.connect next_node if last_node.connections.empty?
        end
      else
        branch_node.connect next_node
      end
    end

    return current_node unless to_step

    to_step.append_to_graphviz(graph)
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

  def graphviz_node(graph, interactive: false)
    if graph.nodes[graphviz_node_key]
      return graph.nodes[graphviz_node_key]
    end

    shape = multi_branch? ? :octagon : :box
    attrs = {
      label: name, shape: shape, style: :filled, fillcolor: :white
    }
    if interactive
      attrs[:href] = Rails.application.routes.url_helpers.edit_pipeline_step_path(pipeline, self)
    end

    Graphviz::Node.new graphviz_node_key, graph, attrs
  end
end
