class UserAuthenticator < ActiveRecord::Migration
  class User < ActiveRecord::Base
    # to turn off validations
  end
  
  def self.up
    add_column :users, :authenticator, :string
    User.reset_column_information
    Incrementally.process( User) do |user|
      if( user.authenticator.blank?)
        user.authenticator = Nonce.generate
        user.save!
      end
    end
  end

  def self.down
    remove_column :users, :authenticator
  end
end
