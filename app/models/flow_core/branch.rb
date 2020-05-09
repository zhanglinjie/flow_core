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

    after_destroy :cascade_destroy_orphan_steps

    private

      def cascade_destroy_orphan_steps
        stack = []
        current_step = step
        loop do
          if current_step.nil? || current_step.from_connections.size > 1
            break
          end

          stack << step
          current_step = current_step.to_step
        end

        stack.each(&:destroy!)
      end
  end
end
