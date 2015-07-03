require 'rails_helper'

RSpec.describe MailingListService do

  describe '#mailing_subscribe' do
    before(:each) do
      @user = create(:user)
      @mailing_list_service = MailingListService.new(@user)
    end

    context 'when list ID is valid and email is valid' do
      it 'returns OK 200' do
        response = VCR.use_cassette('successful_mail_subscription') do
          @mailing_list_service.mailing_subscribe 'fe1087b0aa'
        end
        expect(response).to eq(true)
      end
    end

    context 'when list ID is invalid and email is valid' do
      it 'returns HTTP 500' do
        response = VCR.use_cassette('invalid_id_mail_subscription') do
          @mailing_list_service.mailing_subscribe 'wrong_id'
        end
        expect(response).to eq(false)
      end
    end

    context 'when list ID is valid but email is invalid' do
      it 'returns HTTP 500' do
        user = create(:user)
        user.update_attribute('email', 'WRONG')
        @mailing_list_service = MailingListService.new(user)
        response = VCR.use_cassette('invalid_email_mail_subscription') do
          @mailing_list_service.mailing_subscribe 'fe1087b0aa'
        end
        expect(response).to eq(false)
      end
    end

  end
end
