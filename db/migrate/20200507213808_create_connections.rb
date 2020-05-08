# frozen_string_literal: true

class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_connections do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :flow_core_pipelines }

      t.references :from_step, null: false, foreign_key: { to_table: :flow_core_steps }
      t.references :to_step, null: false, foreign_key: { to_table: :flow_core_steps }

      t.timestamps
    end
  end
end
