# frozen_string_literal: true

module FlowCore
  class Steps::Gateway < FlowCore::Step
    class << self
      def containable?
        true
      end
    end
  end
end
