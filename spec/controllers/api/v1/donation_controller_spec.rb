require 'rails_helper'

describe Api::V1::DonationsController do
  describe '#create' do
    context "when donation is valid" do
      it "returns the donation and sets the status to created" do
        donation = Donation.create(amount: 5)
        stub_donation donation
        post :create, donation: {amount: 5}
        expect(response).to have_http_status(:created)
        expect(assigns[:donation]).to eq(donation)
      end
    end
  end
  def stub_donation(donation)
    allow(donation).to receive(:save).and_return(true)
    allow(Donation).to receive(:new).
      with('amount' => '5').
      and_return(donation)
  end

end
