# frozen_string_literal: true

module FlowCore
  class ProcessFlow < FlowCore::ApplicationRecord
    self.table_name = "flow_core_process_flows"

    has_many :connections, dependent: :delete_all
    has_many :steps, dependent: :delete_all

    after_create :create_default_steps

    private

      def create_default_steps
        start_step = steps.create! name: "Start", type: "FlowCore::Steps::Start"
        end_step = steps.create! name: "End", type: "FlowCore::Steps::End"
        connections.create! source: start_step, destination: end_step
      end
  end
end

require_dependency "flow_core/steps"
