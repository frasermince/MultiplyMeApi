require 'rails_helper'

describe Api::V1::NamesController do
  describe '#show' do
    context 'user specified by id exists' do
      it 'gets the users name based on the user_id' do
        user = create(:user)
        get :show, id: user.id
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['name']).to eq(user.name)
      end
    end
    context 'asks for a user that does not exist' do
      it 'returns a not_found error' do
        get :show, id: -1
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
