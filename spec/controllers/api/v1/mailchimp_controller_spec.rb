require 'rails_helper'

describe Api::V1::MailchimpController do

    describe '#subscribe' do

      context 'when list ID is valid and email is valid' do
        it 'returns OK 200' do
          post :subscribe, id:"fe1087b0aa", email:"medjessy@gmail.com"
          expect(response).to have_http_status(:ok)
        end
      end
      context 'when list ID is invalid and email is valid' do
        it 'returns HTTP 500' do
          post :subscribe, id:"wrong_id", email:"medjessy@gmail.com"
          expect(response).to have_http_status(500)
        end
      end

      context 'when list ID is valid but email is invalid' do
        it 'returns HTTP 500' do
          post :subscribe, id:"fe1087b0aa", email:"wrong_email"
          expect(response).to have_http_status(500)
        end
      end

    end

end
