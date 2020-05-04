# frozen_string_literal: true

module FlowCore
  module Steps
    %w[
      start end task gateway
    ].each do |type|
      require_dependency "flow_core/steps/#{type}"
    end
  end
end
