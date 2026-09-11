# frozen_string_literal: true

class ComplainPage < BasePage
  path '/#/complain'

  def file_complaint(message:)
    fill_in(Locators::COMPLAINT_MESSAGE, with: message)
    self
  end

  def submit
    click_button(Locators::SUBMIT_BUTTON)
    self
  end

  def submit_enabled? = enabled?(Locators::SUBMIT_BUTTON)

  # Logged-in users get their own address filled in and locked.
  def customer_locked? = find(Locators::COMPLAINT_EMAIL_FIELD, wait: 10).disabled?

  def message_limit = find(Locators::COMPLAINT_MESSAGE_FIELD, wait: 10)[:maxlength].to_i
end
