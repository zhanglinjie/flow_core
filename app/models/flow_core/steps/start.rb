# frozen_string_literal: true

module FlowCore
  class Steps::Start < FlowCore::Step
    def movable?
      false
    end

    def appendable?
      true
    end

    def connectable?
      false
    end

    def destroyable?
      false
    end
  end
end
