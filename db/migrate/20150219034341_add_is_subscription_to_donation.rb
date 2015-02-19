class AddIsSubscriptionToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :is_subscription, :boolean, default: true
    add_column :donations, :is_challenged, :boolean, default: true
  end
end
