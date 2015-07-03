require 'rails_helper'

RSpec.configure do |c|
  c.include Stubber
end

describe Api::V1::ShareTreesController do
  before(:each) do
    @parent_donation = create(:donation)
    @child_donation = create(:donation)
    @child_donation.update_attribute('parent_id', @parent_donation.id)
    @second_child = create(:donation)
    @second_child.update_attribute('parent_id', @parent_donation.id)
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the share tree that corresponds with the donation' do
        stub_finding @parent_donation, @parent_donation.id
        get :show, id: @parent_donation.id
        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_body['parent']['image_url']).to be
        expect(parsed_body['parent']['name']).to eq(@parent_donation.user.name)
        expect(parsed_body['children'].first['image_url']).to be
        expect(parsed_body['children'].first['name']).to eq(@child_donation.user.name)
        expect(assigns[:donation]).to eq(@parent_donation)
      end
    end
  end

end
