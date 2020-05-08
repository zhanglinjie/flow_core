# frozen_string_literal: true

module FlowCore
  class Branch < FlowCore::ApplicationRecord
    self.table_name = "flow_core_branches"

    belongs_to :pipeline, class_name: "FlowCore::Pipeline"
    belongs_to :root, class_name: "FlowCore::Step"
    belongs_to :step, class_name: "FlowCore::Step", optional: true

    before_validation do
      self.pipeline ||= root&.pipeline
    end
  end
end
