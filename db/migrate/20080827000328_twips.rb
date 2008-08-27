class Twips < ActiveRecord::Migration
  def self.up
    create_table :twips do |t|
      t.string :title
      t.text :body
      t.integer :owner_id
    end
    
  end

  def self.down
    drop_table :twips
  end
end
