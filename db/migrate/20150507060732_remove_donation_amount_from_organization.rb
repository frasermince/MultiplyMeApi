class RemoveDonationAmountFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :donation_amount
    remove_column :organizations, :donation_count
  end
end
