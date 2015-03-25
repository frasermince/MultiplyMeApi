module DonationStubber
  def stub_donation_finding(donation, id)
    allow(Donation).to receive(:find).
      with(id.to_s).
      and_return(donation)
  end

  def stub_donation_creation(donation, is_saved)
    allow(donation).to receive(:save).and_return(is_saved)
    allow(Donation).to receive(:new).
      with(string_params).
      and_return(donation)
  end

  def expect_stripe_user(donation)
    allow(donation.user).to receive(:save_stripe_user)
    expect(donation.user).to receive(:save_stripe_user)
  end
end
