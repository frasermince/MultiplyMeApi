class ReminderPolicy
  def initialize(donation)
    @donation = donation
  end

  def reminder_valid
    result = (@donation.last_reminder.nil? ||
      @donation.last_reminder < 12.hours.ago) &&
      @donation.is_challenged &&
      !@donation.is_paid
    @donation.update_attribute('last_reminder', DateTime.now)
    result
  end
end
