# frozen_string_literal: true

module FlowCore
  class Engine < ::Rails::Engine
    initializer "flow_core.load_default_i18n" do
      ActiveSupport.on_load(:i18n) do
        I18n.load_path << File.expand_path("locale/en.yml", __dir__)
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
