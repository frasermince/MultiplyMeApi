class AddRecurringAmountToUser < ActiveRecord::Migration
  def change
    add_column :users, :recurring_amount, :integer, default: 0
  end
end
