class CreateOrganizationsUsers < ActiveRecord::Migration
  def change
    create_table :organizations_users do |t|
      t.references :organization, index: true
      t.references :user, index: true
      t.string :stripe_id

      t.timestamps
    end
  end
end
