# frozen_string_literal: true

module FlowCore
  class Pipeline < FlowCore::ApplicationRecord
    self.table_name = "flow_core_pipelines"

    has_many :connections, class_name: "FlowCore::Connection", dependent: :delete_all
    has_many :steps, class_name: "FlowCore::Step", dependent: :delete_all
    has_many :branches, class_name: "FlowCore::Branch", dependent: :delete_all

    belongs_to :start_step, class_name: "FlowCore::Step", optional: true
    belongs_to :end_step, class_name: "FlowCore::Step", optional: true

    after_create :create_default_steps

    private

      def create_default_steps
        create_start_step! pipeline: self, name: "Start"
        create_end_step! pipeline: self, name: "End"
        connections.create! from_step: start_step, to_step: end_step
        save!
      end
  end
end
