# frozen_string_literal: true

module FlowCore
  class Steps::End < FlowCore::Step

    class << self
      def movable?
        false
      end

      def appendable?
        false
      end

      def connectable?
        true
      end

      def creatable?
        false
      end

      def destroyable?
        false
      end
    end
  end
end
