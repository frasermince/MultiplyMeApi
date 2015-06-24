class AddReferralCodeToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :referral_code, :string
  end
end
