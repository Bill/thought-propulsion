class UserCreate < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :identity_url
      t.string :nickname
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :zip
      t.string :country
    end
    
  end

  def self.down
    drop_table :users
  end
end
