# frozen_string_literal: true

module FlowCore
  class Connection < FlowCore::ApplicationRecord
    self.table_name = "flow_core_connections"

    belongs_to :pipeline

    belongs_to :from_step, class_name: "FlowCore::Step"
    belongs_to :to_step, class_name: "FlowCore::Step"
  end
end
