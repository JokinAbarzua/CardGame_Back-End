class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :game, null: false, foreign_key: true      
      t.integer :role    
      t.integer :team
      t.string :hand, array: true
      t.integer :seat
      t.string :played, array: true #cartas jugadas

      t.timestamps
    end
  end
end
