# frozen_string_literal: true

class Pipelines::Steps::BranchesController < Pipelines::Steps::ApplicationController
  before_action :set_branch, only: %i[edit update destroy]

  def new
    @branch = @step.branches.new
  end

  def edit; end

  def create
    @branch = @step.branches.new(branch_params)

    if @branch.save
      redirect_to pipeline_url(@pipeline), notice: "Branch was successfully created."
    else
      render :new
    end
  end

  def update
    if @branch.update(branch_params)
      redirect_to pipeline_url(@pipeline), notice: "Branch was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @branch.destroy

    redirect_to pipeline_url(@pipeline), notice: "Branch was successfully destroyed."
  end

  private

    def set_branch
      @branch = @step.branches.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit(:name, :type, :step_id)
    end
end
