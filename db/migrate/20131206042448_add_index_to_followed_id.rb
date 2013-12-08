class AddIndexToFollowedId < ActiveRecord::Migration
  def change
  	add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end

  def down
  	Relationship.delete_all
  end
end
