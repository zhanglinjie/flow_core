# frozen_string_literal: true

module FlowCore
  class Step < FlowCore::ApplicationRecord
    self.table_name = "flow_core_steps"

    belongs_to :pipeline, class_name: "FlowCore::Pipeline"

    has_many :connected_branches, class_name: "FlowCore::Branch", foreign_key: :step_id, inverse_of: :step, dependent: :nullify
    has_many :branches, class_name: "FlowCore::Branch", foreign_key: :root_id, inverse_of: :root, dependent: :destroy

    has_many :from_connections, foreign_key: :to_step_id, class_name: "FlowCore::Connection", inverse_of: :to_step, dependent: :restrict_with_error
    has_many :from_steps, through: :from_connections, class_name: "FlowCore::Step"
    has_one :to_connection, foreign_key: :from_step_id, class_name: "FlowCore::Connection", inverse_of: :from_step, dependent: :restrict_with_error
    has_one :to_step, through: :to_connection, class_name: "FlowCore::Step"

    before_destroy :handle_connection_on_destroy, prepend: true

    attr_accessor :append_to_step_id, :append_to_branch_id
    after_create :append_to_step_on_create, :append_to_branch_on_create

    def start_step?
      pipeline.start_step_id == id
    end

    def end_step?
      pipeline.end_step_id == id
    end

    def append_to(target)
      return unless movable?

      case target
      when FlowCore::Step
        append_to_step target
      when FlowCore::Branch
        append_to_branch target
      else
        raise ArgumentError, "Unsupported type `#{target.class}`"
      end
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

    delegate :user_creatable?, :user_editable?, :user_destroyable?,
             :multi_branch?, :user_branch_creatable?,
             to: :class, allow_nil: false

    def appendable?
      self.class.appendable? && !end_step?
    end

    def connectable?
      self.class.connectable? && !start_step?
    end

    def movable?
      self.class.movable? && !start_step? && !end_step?
    end

    def user_destroyable?
      !(start_step? || end_step?)
    end

    class << self
      def multi_branch?
        false
      end

      def user_branch_creatable?
        false
      end

      def user_creatable?
        true
      end

      def user_editable?
        true
      end

      def user_destroyable?
        true
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
    end

    private

      def append_to_step(step)
        return unless step&.appendable?
        return if step == self
        return if step.to_step == self

        original_to_step = step.to_step

        transaction do
          step.to_connection&.destroy
          pipeline.connections.create! from_step: step, to_step: self
          if original_to_step
            pipeline.connections.create! from_step: self, to_step: original_to_step
          end
        end

        true
      rescue ActiveRecord::Rollback
        false
      ensure
        reload
        step.reload
      end

      def append_to_branch(branch)
        return if branch.root == self

        original_step = branch.step
        transaction do
          branch.update! step: self
          original_step&.append_to self
        end
      rescue ActiveRecord::Rollback
        false
      ensure
        branch.reload
      end

      def handle_connection_on_destroy
        if to_step
          connected_branches.update_all(step_id: to_step.id)
          from_connections.update_all(to_step_id: to_step.id)
          to_connection.delete
          self.to_connection = nil
        else
          from_connections.delete_all
        end
      end

      def append_to_step_on_create
        return if append_to_step_id.blank?

        step = pipeline.steps.find(append_to_step_id)
        append_to step
      end

      def append_to_branch_on_create
        return if append_to_branch_id.blank?

        branch = pipeline.branches.find(append_to_branch_id)
        append_to branch
      end
  end
end
