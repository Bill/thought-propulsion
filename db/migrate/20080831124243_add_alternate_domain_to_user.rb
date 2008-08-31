class AddAlternateDomainToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :alternate_domain, :string
  end

  def self.down
    remove_column :users, :alternate_domain
  end
end
