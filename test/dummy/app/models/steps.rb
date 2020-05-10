# frozen_string_literal: true

module Steps
  def self.creatable_types
    @creatable_types ||= [
      Steps::Task,
      Steps::Gateway
    ]
  end
end
