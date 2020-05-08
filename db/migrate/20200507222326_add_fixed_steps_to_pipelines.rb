# frozen_string_literal: true

class AddFixedStepsToPipelines < ActiveRecord::Migration[6.0]
  def change
    change_table :flow_core_pipelines do |t|
      t.references :start_step, foreign_key: { to_table: :flow_core_steps }
      t.references :end_step, foreign_key: { to_table: :flow_core_steps }
    end
  end
end
