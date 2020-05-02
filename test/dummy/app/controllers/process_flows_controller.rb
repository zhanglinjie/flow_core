# frozen_string_literal: true

class ProcessFlowsController < ApplicationController
  before_action :set_process_flow, only: %i[show edit update destroy]

  def index
    @process_flows = FlowCore::ProcessFlow.all
  end

  def show; end

  def new
    @process_flow = FlowCore::ProcessFlow.new
  end

  def edit; end

  def create
    @process_flow = FlowCore::ProcessFlow.new(process_flow_params)

    if @process_flow.save
      redirect_to process_flow_url(@process_flow), notice: "Process flow was successfully created."
    else
      render :new
    end
  end

  def update
    if @process_flow.update(process_flow_params)
      redirect_to process_flow_url(@process_flow), notice: "Process flow was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @process_flow.destroy
    redirect_to process_flows_url, notice: "Process flow was successfully destroyed."
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_process_flow
      @process_flow = FlowCore::ProcessFlow.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def process_flow_params
      params.require(:process_flow).permit(:name)
    end
end
