class User < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :identity_url
      t.string :nickname
    end
    
  end

  def self.down
    drop_table :users
  end
end
