class AddPublicToTwip < ActiveRecord::Migration
  def self.up
    add_column :twips, :public, :boolean, :default => false
  end

  def self.down
    remove_column :twips, :public
  end
end
