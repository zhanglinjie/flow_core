# frozen_string_literal: true

module FlowCore
  module Steps
    def self.creatable_types
      @creatable_types ||= [
        FlowCore::Steps::Task,
        FlowCore::Steps::Gateway
      ]
    end
  end
end
