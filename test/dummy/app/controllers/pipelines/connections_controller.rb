# frozen_string_literal: true

class Pipelines::ConnectionsController < Pipelines::ApplicationController
  before_action :set_connection, only: %i[edit update destroy]

  def new
    @connection = @pipeline.connections.new
    if params[:from_step_id].present?
      @connection.from_step = @pipeline.steps.find_by id: params[:from_step_id]
    end
  end

  def edit; end

  def create
    @connection = @pipeline.connections.new connection_params

    if @connection.save
      redirect_to pipeline_url(@pipeline), notice: "Connection was successfully created."
    else
      render :new
    end
  end

  def update
    if @connection.update(connection_params)
      redirect_to pipeline_url(@pipeline), notice: "Connection was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @connection.destroy

    redirect_to pipeline_url(@pipeline), notice: "Connection was successfully destroyed."
  end

  private

    def set_connection
      @connection = @pipeline.connections.find(params[:id])
    end

    def connection_params
      params.require(:connection).permit(:from_step_id, :to_step_id)
    end
end
