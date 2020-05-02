# frozen_string_literal: true

class ProcessFlows::ApplicationController < ::ApplicationController
  before_action :set_process_flow

  protected

    def set_process_flow
      @process_flow = FlowCore::ProcessFlow.find(params[:process_flow_id])
    end
end
