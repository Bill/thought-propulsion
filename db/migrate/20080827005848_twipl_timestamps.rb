class TwiplTimestamps < ActiveRecord::Migration
  def self.up
    add_column :twips, :created_at, :timestamp
    add_column :twips, :updated_at, :timestamp
  end

  def self.down
    remove_column :twips, :updated_at
    remove_column :twips, :created_at
  end
end
