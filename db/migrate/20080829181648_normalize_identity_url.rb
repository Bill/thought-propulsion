class NormalizeIdentityUrl < ActiveRecord::Migration
  def self.up
    add_column :users, :normalized_identity_url, :string
    User.reset_column_information
    Incrementally.process( User) do |user|
      # normalize nicknames
      user.nickname = user.id.to_s
      # normalize identity URLs
      user.identity_url = user.identity_url
      user.save!
    end
  end

  def self.down
    remove_column :users, :normalized_identity_url
  end
end
