# frozen_string_literal: true

class PipelinesController < ApplicationController
  before_action :set_pipeline, only: %i[show edit update destroy]

  def index
    @pipelines = FlowCore::Pipeline.all
  end

  def show; end

  def new
    @pipeline = FlowCore::Pipeline.new
  end

  def edit; end

  def create
    @pipeline = FlowCore::Pipeline.new(pipeline_params)

    if @pipeline.save
      redirect_to pipeline_url(@pipeline), notice: "Pipeline was successfully created."
    else
      render :new
    end
  end

  def update
    if @pipeline.update(pipeline_params)
      redirect_to pipeline_url(@pipeline), notice: "Pipeline was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @pipeline.destroy
    redirect_to pipelines_url, notice: "Pipeline was successfully destroyed."
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_pipeline
      @pipeline = FlowCore::Pipeline.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pipeline_params
      params.require(:pipeline).permit(:name)
    end
end
