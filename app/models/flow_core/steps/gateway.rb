# frozen_string_literal: true

module FlowCore
  class Steps::Gateway < FlowCore::Step
    class << self
      def multi_branch?
        true
      end

      def user_branch_creatable?
        true
      end
    end
  end
end
