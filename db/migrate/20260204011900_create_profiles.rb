class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :name, null: false
      t.string :short_github_url
      t.string :github_username
      t.integer :followers, default: 0
      t.integer :following, default: 0
      t.integer :stars, default: 0
      t.integer :contributions_last_year, default: 0
      t.string :avatar_url
      t.string :location
      t.jsonb :organizations, default: []
      t.string :scraping_status, default: 'pending'
      t.text :last_error
      t.datetime :last_scanned_at

      t.timestamps
    end

    add_index :profiles, :short_github_url, unique: true
    add_index :profiles, :github_username
  end
end
