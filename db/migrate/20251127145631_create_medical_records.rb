class CreateMedicalRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :medical_records do |t|
      t.text :diagnosis
      t.text :treatment
      t.text :notes
      t.references :patient, null: false, foreign_key: true
      t.references :practitioner, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
