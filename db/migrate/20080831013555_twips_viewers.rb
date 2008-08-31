class TwipsViewers < ActiveRecord::Migration
  def self.up
    create_table :twips_viewers, :force => true do |t|
      t.integer :twip_id
      t.string :viewer_openid
      t.timestamps
    end
  end

  def self.down
    drop_table :twips_viewers
  end
end
