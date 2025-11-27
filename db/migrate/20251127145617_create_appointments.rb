class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.datetime :scheduled_at, null: false
      t.integer :duration_minutes, null: false, default: 30
      t.integer :status, null: false, default: 0
      t.text :notes
      t.references :patient, null: false, foreign_key: true
      t.references :practitioner, null: false, foreign_key: true

      t.timestamps
    end
    add_index :appointments, [:practitioner_id, :scheduled_at]
    add_index :appointments, [:patient_id, :scheduled_at]
  end
end
