class AddOrganizationToDonation < ActiveRecord::Migration
  def change
    add_reference :donations, :organization, index: true
  end
end
