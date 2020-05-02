# frozen_string_literal: true

class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_connections do |t|
      t.references :process_flow, null: false, foreign_key: { to_table: :flow_core_process_flows }

      t.references :source, null: false, foreign_key: { to_table: :flow_core_steps }
      t.references :destination, null: false, foreign_key: { to_table: :flow_core_steps }

      t.timestamps
    end
  end
end
