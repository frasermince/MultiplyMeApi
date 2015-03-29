class AddImpactToUsers < ActiveRecord::Migration
  def change
    add_column :users, :impact, :int, default: 0
  end
end
