# frozen_string_literal: true

FlowCore::Step.class_eval do
  def append_to_graphviz(graph, interactive:)
    if multi_branch?
      return append_children_to_graphviz(graph, interactive: interactive)
    end

    current_node = graphviz_node(graph)
    graph << current_node unless graph.nodes[graphviz_node_key]

    return current_node if current_node.connections.any?

    if interactive && appendable?
      append_to_current_node =
        Graphviz::Node.new append_to_node_key, graph,
                           label: "+ Task", shape: :box, style: "dashed, filled", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to_step_id: id)

      return append_to_current_node if current_node.connected?(append_to_node_key)

      current_node.connect append_to_current_node, arrowhead: :none

      last_node = append_to_current_node
    else
      last_node = current_node
    end

    if to_step
      next_node = to_step.graphviz_node(graph)

      return last_node if last_node.connected? next_node

      last_node.connect next_node, weight: (next_node.connections.any? ? 0 : 10),
                                   href: Rails.application.routes.url_helpers.edit_pipeline_connection_path(pipeline, to_connection)

      to_step.append_to_graphviz(graph, interactive: interactive)
    else
      last_node
    end
  end

  def append_children_to_graphviz(graph, interactive:)
    current_node = graphviz_node(graph)

    return current_node if current_node.connections.any?

    if branches.empty?
      if interactive
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

        last_node = append_to_current_node
      else
        last_node = current_node
      end

      if to_step
        next_node = to_step&.graphviz_node(graph)

        return last_node if last_node.connected? next_node

        last_node.connect next_node, arrowhead: :none

        return to_step.append_to_graphviz(graph, interactive: interactive)
      else
        return last_node
      end
    end

    if interactive
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
          child_node = child_step&.graphviz_node(graph)
          append_to_branch_node.connect child_node
          last_node = child_step.append_to_graphviz(graph, interactive: interactive)
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

      next_node = to_step.graphviz_node(graph)

      append_to_current_node.connect next_node
    else
      next_node = to_step&.graphviz_node(graph)

      branches.each do |branch|
        branch_node_key = "step_#{id}_branch_#{branch.id}"
        branch_node =
          Graphviz::Node.new branch_node_key, graph,
                             label: branch.name, shape: :oval, style: :filled, fillcolor: :white

        child_step = branch.step
        next unless child_step

        child_node = child_step.graphviz_node(graph)

        current_node.connect branch_node, arrowhead: :none
        branch_node.connect child_node

        last_node = child_step.append_to_graphviz(graph, interactive: interactive)
        if next_node && last_node.connections.empty?
          last_node.connect next_node, style: :dashed
        end
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

    shape = multi_branch? ? :octagon : :box
    Graphviz::Node.new graphviz_node_key, graph, label: name, shape: shape, style: :filled, fillcolor: :white,
                                                 href: Rails.application.routes.url_helpers.edit_pipeline_step_path(pipeline, self)
  end
end
