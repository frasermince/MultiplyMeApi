class ChangeAmountTypeInDonations < ActiveRecord::Migration
  def up
    change_column :donations, :amount, :integer
  end

  def down
    change_column :donations, :amount, :float
  end
end
