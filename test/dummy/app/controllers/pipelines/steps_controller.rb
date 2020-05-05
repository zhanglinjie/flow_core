# frozen_string_literal: true

class Pipelines::StepsController < Pipelines::ApplicationController
  before_action :set_step, only: %i[edit update destroy]

  def new
    @step = @pipeline.steps.new
    @step.append_to_step_id = params[:append_to_step_id]
    @step.add_to_container_step_id = params[:add_to_container_step_id]
  end

  def edit; end

  def create
    @step = @pipeline.steps.new(step_params)

    if @step.save
      redirect_to pipeline_url(@pipeline), notice: "Step was successfully created."
    else
      render :new
    end
  end

  def update
    if @step.update(step_params)
      redirect_to pipeline_url(@pipeline), notice: "Step was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @step.destroy

    redirect_to pipeline_url(@pipeline), notice: "Step was successfully destroyed."
  end

  private

    def set_step
      @step = @pipeline.steps.find(params[:id])
    end

    def step_params
      params.require(:step).permit(:name, :type, :append_to_step_id, :add_to_container_step_id)
    end
end
