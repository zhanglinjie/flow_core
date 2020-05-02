# frozen_string_literal: true

module FlowCore
  class Connection < FlowCore::ApplicationRecord
    self.table_name = "flow_core_connections"

    belongs_to :process_flow

    belongs_to :source, class_name: "FlowCore::Step"
    belongs_to :destination, class_name: "FlowCore::Step"
  end
end
