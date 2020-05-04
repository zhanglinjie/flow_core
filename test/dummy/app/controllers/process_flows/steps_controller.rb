# frozen_string_literal: true

class ProcessFlows::StepsController < ProcessFlows::ApplicationController
  before_action :set_step, only: %i[edit update destroy]

  def new
    @step = @process_flow.steps.new
    @step.append_to_id = params[:append_to_id]
  end

  def edit; end

  def create
    @step = @process_flow.steps.new(step_params)

    if @step.save
      redirect_to process_flow_url(@process_flow), notice: "Step was successfully created."
    else
      render :new
    end
  end

  def update
    if @step.update(step_params)
      redirect_to process_flow_url(@process_flow), notice: "Step was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @step.destroy

    redirect_to process_flow_url(@process_flow), notice: "Step was successfully destroyed."
  end

  private

    def set_step
      @step = @process_flow.steps.find(params[:id])
    end

    def step_params
      params.require(:step).permit(:name, :append_to_id)
    end
end
