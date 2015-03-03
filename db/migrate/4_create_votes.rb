class CreateVotes < ActiveRecord::Migration

  def change
    create_table :votes do |t|
      t.integer :point
      t.integer :user_id
      t.integer :story_id

      t.timestamps null: false
    end
  end
end
