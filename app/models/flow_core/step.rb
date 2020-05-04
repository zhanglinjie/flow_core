# frozen_string_literal: true

module FlowCore
  class Step < FlowCore::ApplicationRecord
    self.table_name = "flow_core_steps"

    belongs_to :process_flow

    belongs_to :parent, class_name: "FlowCore::Step", optional: true
    has_many :children, class_name: "FlowCore::Step", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

    has_many :source_connections, foreign_key: :destination_id, class_name: "FlowCore::Connection", inverse_of: :destination, dependent: :nullify
    has_many :sources, through: :source_connections, class_name: "FlowCore::Step"
    has_one :destination_connection, foreign_key: :source_id, class_name: "FlowCore::Connection", inverse_of: :source, dependent: :nullify
    has_one :destination, through: :destination_connection, class_name: "FlowCore::Step"

    attr_accessor :append_to_id
    after_create :append_to_step

    def append_to(another_step)
      return unless movable?
      return unless another_step&.appendable?
      return if another_step == self
      return if another_step.destination == self

      original_destination = another_step.destination

      transaction do
        another_step.destination_connection&.destroy
        process_flow.connections.create! source: another_step, destination: self
        if original_destination
          process_flow.connections.create! source: self, destination: original_destination
        end
      end

      true
    rescue ActiveRecord::Rollback
      false
    ensure
      reload
      another_step.reload
    end

    def connect_to(another_step)
      return unless another_step&.connectable?
      return if another_step == self

      if destination
        return if destination == another_step
        return if destination.source_connections.size == 1
      end

      connection = process_flow.connections.create source: self, destination: another_step
      connection.persisted?
    ensure
      reload
      another_step.reload
    end

    def movable?
      true
    end

    def appendable?
      true
    end

    def connectable?
      true
    end

    def destroyable?
      true
    end

    private

      def append_to_step
        return if append_to_id.blank?

        another_step = process_flow.steps.find(append_to_id)
        append_to another_step
      end
  end
end
