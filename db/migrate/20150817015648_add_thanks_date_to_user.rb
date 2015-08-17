class AddThanksDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :thanks_date, :datetime
  end
end
