class AddUserToDonation < ActiveRecord::Migration
  def change
    add_reference :donations, :user, index: true
  end
end
