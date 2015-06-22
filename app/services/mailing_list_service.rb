class MailingListService
  def initialize(user)
    @user = user
    @errors = []
  end

  def errors
    @errors
  end

  def mailing_subscribe(list_id)
    @mailchimp = Mailchimp::API.new Rails.application.secrets.mailchimp_api_key
    email = @user.email
    begin
      @mailchimp.lists.subscribe(list_id , {'email' => email})
    rescue Mailchimp::Error => ex
      if ex.message
        @errors.push ex.message
      else
        @errors.push  "An unknown error occurred"
      end
      return false
    end
    true
  end
end
