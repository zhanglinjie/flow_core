# frozen_string_literal: true

module FlowCore
  class ProcessFlow < FlowCore::ApplicationRecord
    self.table_name = "flow_core_process_flows"

    has_many :connections, dependent: :delete_all
    has_many :steps, dependent: :delete_all
  end
end
