# frozen_string_literal: true

class Pipelines::Steps::ToConnectionsController < Pipelines::Steps::ApplicationController
  before_action :set_to_connection, only: %i[edit update destroy]

  def new
    @connection = @step.build_to_connection
  end

  def edit; end

  def create
    @connection = @step.build_to_connection(connection_params)

    if @connection.save
      redirect_to pipeline_url(@pipeline), notice: "Connection was successfully created."
    else
      render :new
    end
  end

  def update
    if @connection.update(connection_params)
      redirect_to pipeline_url(@pipeline), notice: "Branch was successfully updated."
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
      @connection = @step.to_connection
    end

    def connection_params
      params.require(:connection).permit(:to_step_id)
    end
end
