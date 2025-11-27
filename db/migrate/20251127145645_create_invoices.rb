class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.date :due_date, null: false
      t.datetime :paid_at
      t.text :description
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, foreign_key: true

      t.timestamps
    end
    add_index :invoices, :status
    add_index :invoices, :due_date
  end
end
