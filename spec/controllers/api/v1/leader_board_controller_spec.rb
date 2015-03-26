require 'rails_helper'

describe Api::V1::LeaderBoardController do

    describe '#index' do

      context 'when no limit is passed' do
        it 'returns the 10 top leaders as max' do
          get :index
          expect(response).to have_http_status(200)
          parsed_body = JSON.parse(response.body)
          expect(parsed_body['leaders']).to be
          expect(parsed_body['leaders'].count).to be <= 10
        end
      end

      context 'when limit is passed' do
        it 'returns the limit numbers of top leaders as max' do
          get :index, limit: 6
          expect(response).to have_http_status(200)
          parsed_body = JSON.parse(response.body)
          expect(parsed_body['leaders']).to be
          expect(parsed_body['leaders'].count).to be <= 6
        end
      end

    end

end
