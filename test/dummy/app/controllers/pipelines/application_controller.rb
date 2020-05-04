# frozen_string_literal: true

class Pipelines::ApplicationController < ::ApplicationController
  before_action :set_pipeline

  protected

    def set_pipeline
      @pipeline = FlowCore::Pipeline.find(params[:pipeline_id])
    end
end
