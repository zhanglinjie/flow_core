# frozen_string_literal: true

module FlowCore
  class Step < FlowCore::ApplicationRecord
    self.table_name = "flow_core_steps"

    belongs_to :process_flow

    belongs_to :parent, class_name: "FlowCore::Step", optional: true
    has_many :children, class_name: "FlowCore::Step", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

    has_many :source_connections, class_name: "FlowCore::Connection", inverse_of: :source, dependent: :nullify
    has_one :destination_connection, class_name: "FlowCore::Connection", inverse_of: :destination, dependent: :nullify
  end
end
