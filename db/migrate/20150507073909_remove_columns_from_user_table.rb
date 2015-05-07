class RemoveColumnsFromUserTable < ActiveRecord::Migration
  def change
    remove_column :users, :network_impact
    remove_column :users, :personal_impact
    remove_column :users, :recurring_amount
  end
end
