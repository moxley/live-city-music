
class CreateJobRuns < ActiveRecord::Migration
  def change
    create_table :job_runs do |t|
      t.string :job_type, limit: 30, null: false
      t.string :sub_type, limit: 30
      t.string :target_type, limit: 30, null: false
      t.integer :target_id, null: false
      t.string :status, limit: 20
      t.string :error_id, limit: 20

      t.timestamps
    end

    add_index :job_runs, :job_type
    add_index :job_runs, [:target_type, :target_id]
    add_index :job_runs, :error_id
  end
end
