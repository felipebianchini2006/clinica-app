class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.string :name, null: false
      t.string :cpf, null: false
      t.date :birth_date
      t.string :phone
      t.string :email
      t.text :address
      t.text :notes

      t.timestamps
    end
    add_index :patients, :cpf, unique: true
  end
end
