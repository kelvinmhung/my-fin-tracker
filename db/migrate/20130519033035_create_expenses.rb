class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.timestamp :date
      t.string :description
      t.string :category
      t.money :amount
      t.integer :user_id

      t.timestamps
    end
  end
end
