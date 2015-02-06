class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :stripe_access_token

      t.timestamps
    end
  end
end
