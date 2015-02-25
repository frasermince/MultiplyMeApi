class AddStripeIdToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :stripe_id, :string
  end
end
