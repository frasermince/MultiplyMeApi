class AddCancelledTimeToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :cancelled_time, :datetime
  end
end
