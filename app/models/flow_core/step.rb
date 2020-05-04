# frozen_string_literal: true

module FlowCore
  class Step < FlowCore::ApplicationRecord
    self.table_name = "flow_core_steps"

    belongs_to :pipeline, class_name: "FlowCore::Pipeline"

    belongs_to :parent, class_name: "FlowCore::Step", optional: true
    has_many :children, class_name: "FlowCore::Step", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

    has_many :from_connections, foreign_key: :to_step_id, class_name: "FlowCore::Connection", inverse_of: :to_step, dependent: :nullify
    has_many :from_steps, through: :from_connections, class_name: "FlowCore::Step"
    has_one :to_connection, foreign_key: :from_step_id, class_name: "FlowCore::Connection", inverse_of: :from_step, dependent: :nullify
    has_one :to_step, through: :to_connection, class_name: "FlowCore::Step"

    attr_accessor :append_to_step_id
    after_create :append_to_step

    def append_to(another_step)
      return unless movable?
      return unless another_step&.appendable?
      return if another_step == self
      return if another_step.to_step == self

      original_to_step = another_step.to_step

      transaction do
        another_step.to_connection&.destroy
        pipeline.connections.create! from_step: another_step, to_step: self
        if original_to_step
          pipeline.connections.create! from_step: self, to_step: original_to_step
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

      if to_step
        return if to_step == another_step
        return if to_step.from_connections.size == 1
      end

      connection = pipeline.connections.create from_step: self, to_step: another_step
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

    def creatable?
      true
    end

    def editable?
      true
    end

    private

      def append_to_step
        return if append_to_step_id.blank?

        another_step = pipeline.steps.find(append_to_step_id)
        append_to another_step
      end
  end
end
