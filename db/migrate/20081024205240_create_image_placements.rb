class CreateImagePlacements < ActiveRecord::Migration
  def self.up
    create_table :image_placements do |t|
      t.belongs_to :twip
      t.references :image

      t.timestamps
    end
  end

  def self.down
    drop_table :image_placements
  end
end
