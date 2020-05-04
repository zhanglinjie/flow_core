# frozen_string_literal: true

module FlowCore
  class Steps::End < FlowCore::Step
    def movable?
      false
    end

    def appendable?
      false
    end

    def connectable?
      true
    end

    def destroyable?
      false
    end
  end
end
