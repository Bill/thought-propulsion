class Images < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      
      # attachment-fu fields
      # see attachment-fu plugin documentation
      t.integer :parent_id
      t.string :content_type
      t.string :filename   
      t.string :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      
      # Twipl authorship
      t.belongs_to :owner
      t.boolean :public, :default => false
      
      # Twipl other information
      t.timestamps

    end
    
  end

  def self.down
    drop_table :images
  end
end