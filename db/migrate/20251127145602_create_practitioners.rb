class CreatePractitioners < ActiveRecord::Migration[8.1]
  def change
    create_table :practitioners do |t|
      t.string :name
      t.string :specialty
      t.string :crm
      t.string :phone
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :practitioners, :crm, unique: true
  end
end
