# frozen_string_literal: true

class CreatePipelines < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_pipelines do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
