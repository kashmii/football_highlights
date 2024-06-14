class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :league, null: false, default: 0
      t.integer :game_week, null: false
      t.datetime :kickoff_time, null: false
      t.string :home_team, null: false
      t.string :away_team, null: false
      t.string :highlight_url
      t.boolean :is_tweeted, default: false

      t.timestamps
    end

    add_index :games, [:league, :game_week, :home_team], unique: true
  end
end
