class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :parent_id
      t.float :amount
      t.integer :downline_count, :default => 0
      t.float :downline_amount, :default => 0

      t.timestamps
    end
  end
end
