class Thumbnails < ActiveRecord::Migration
  def self.up
    create_table :thumbnail_images do |t|
      
      # attachment-fu fields
      # see attachment-fu plugin documentation
      t.integer :parent_id
      t.string :content_type
      t.string :filename   
      t.string :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height

    end
    
  end

  def self.down
    drop_table :thumbnail_images
  end
end
