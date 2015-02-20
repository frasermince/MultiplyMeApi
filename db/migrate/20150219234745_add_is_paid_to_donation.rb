class AddIsPaidToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :is_paid, :boolean, default: false
  end
end
