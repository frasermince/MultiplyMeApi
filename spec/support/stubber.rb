module Stubber
  def stub_finding(record, id)
    allow(record.class).to receive(:find).
      with(id.to_s).
      and_return(record)
  end

  def stub_creation(record, is_saved)
    allow(record).to receive(:save).and_return(is_saved)
    allow(record.class).to receive(:new).
      with(string_params).
      and_return(record)
  end

  def expect_stripe_user(record)
    allow_any_instance_of(StripeUserService).to receive(:save_stripe_user).and_return({status: :success})
    expect_any_instance_of(StripeUserService).to receive(:save_stripe_user)
  end
end
