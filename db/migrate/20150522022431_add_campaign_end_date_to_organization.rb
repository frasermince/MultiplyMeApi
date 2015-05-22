class AddCampaignEndDateToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :campaign_end_date, :datetime
  end
end
