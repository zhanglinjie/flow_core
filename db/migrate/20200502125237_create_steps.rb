# frozen_string_literal: true

class CreateSteps < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_steps do |t|
      t.references :process_flow, null: false, foreign_key: { to_table: :flow_core_process_flows }
      t.references :parent, foreign_key: { to_table: :flow_core_steps }
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end