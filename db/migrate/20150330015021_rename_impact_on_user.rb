class RenameImpactOnUser < ActiveRecord::Migration
  def change
    rename_column :users, :impact, :network_impact
    add_column :users, :personal_impact, :int, default: 0
  end
end
