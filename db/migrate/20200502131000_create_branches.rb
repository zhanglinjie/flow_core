# frozen_string_literal: true

class CreateBranches < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_branches do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :flow_core_pipelines }
      t.references :root, null: false, foreign_key: { to_table: :flow_core_steps }
      t.references :step, foreign_key: { to_table: :flow_core_steps }
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
