class AddLastReminderToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :last_reminder, :datetime
  end
end
