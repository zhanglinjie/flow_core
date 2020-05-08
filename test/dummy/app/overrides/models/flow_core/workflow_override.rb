# frozen_string_literal: true

FlowCore::Workflow.class_eval do
  def internal?
    false
  end

  def to_graphviz(instance: nil)
    graph = Graphviz::Graph.new(rankdir: "LR", splines: :spline, ratio: :auto)
    free_token_places =
      if instance
        instance.tokens.where(stage: %i[free locked]).map(&:place_id)
      else
        []
      end

    pg_mapping = {}
    places.order(id: :asc).each do |p|
      if p.start?
        fillcolor = :yellow
        shape     = :doublecircle
      elsif p.end?
        fillcolor = :green
        shape     = :doublecircle
      else
        fillcolor = :lightpink
        shape     = :circle
      end

      token_count = free_token_places.count(p.id)
      label = token_count.positive? ? "&bull;" * token_count : ""
      xlabel = p.name

      node = Graphviz::Node.new p.name, graph, xlabel: xlabel, label: label, shape: shape, fixedsize: true, style: :filled, fillcolor: fillcolor
      pg_mapping[p] = node
    end

    tg_mapping = {}
    transitions.each do |t|
      node = Graphviz::Node.new t.name, graph, label: t.name, shape: :box, style: :filled, fillcolor: :lightblue
      tg_mapping[t] = node
    end

    arcs.order("direction desc").each do |arc|
      label =
        if arc.guards.size.positive?
          arc.guards.map(&:description).join(" & ")
        else
          ""
        end

      if arc.in?
        from = pg_mapping.fetch(arc.place)
        to = tg_mapping.fetch(arc.transition)
      else
        from = tg_mapping.fetch(arc.transition)
        to = pg_mapping.fetch(arc.place)
      end

      from.connect to, label: label, labelfloat: false, labelfontcolor: :red, arrowhead: :vee
    end

    graph
  end
end
