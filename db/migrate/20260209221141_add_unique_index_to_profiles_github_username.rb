class AddUniqueIndexToProfilesGithubUsername < ActiveRecord::Migration[8.1]
  def change
    # Remove o índice antigo não-único
    remove_index :profiles, :github_username, if_exists: true

    # Adiciona índice único (case insensitive)
    add_index :profiles, "LOWER(github_username)", unique: true, name: "index_profiles_on_lower_github_username"
  end
end
