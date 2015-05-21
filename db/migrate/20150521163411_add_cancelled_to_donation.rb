class AddCancelledToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :is_cancelled, :boolean, default: false
  end
end
