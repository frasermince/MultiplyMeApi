class AddFieldsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :donation_amount, :integer, default: 0
    add_column :organizations, :donation_count, :integer, default: 0
  end
end
