class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :points_us, default: 0
      t.integer :points_them, default: 0
      t.integer :us_count, default: 1
      t.integer :players_count, default: 0
      t.integer :size
      t.integer :state, default: 0 #empeza en waiting
      t.string :number
      t.string :deck,array: true
      t.integer :deals,default: 0 #quien tiene el turno de repartir

      t.timestamps
    end
  end
end
