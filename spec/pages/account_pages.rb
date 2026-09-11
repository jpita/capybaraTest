# frozen_string_literal: true

class OrderHistoryPage < BasePage
  path '/#/order-history'

  def empty? = has_text?('You have not placed any orders yet.', wait: 10)
  def order_ids = all(Locators::ORDER_HEADING, minimum: 0).map { |card| card.text[/#(\S+)/, 1] }
  def contains_order?(id) = has_text?(id, wait: 10)
end

class SavedAddressesPage < BasePage
  path '/#/address/saved'

  def names = all(Locators::ADDRESS_NAME_CELL, minimum: 0).map(&:text)
  def contains?(name) = has_css?(Locators::ROW, text: name, wait: 10)
end

class AdministrationPage < BasePage
  path '/#/administration'
end

class AccountingPage < BasePage
  path '/#/accounting'
end

class DeluxeMembershipPage < BasePage
  path '/#/deluxe-membership'
end

class DataExportPage < BasePage
  path '/#/privacy-security/data-export'
end

class LastLoginIpPage < BasePage
  path '/#/privacy-security/last-login-ip'
end

class TwoFactorAuthPage < BasePage
  path '/#/privacy-security/two-factor-authentication'
end

class PrivacyPolicyPage < BasePage
  path '/#/privacy-security/privacy-policy'
end

class SavedPaymentMethodsPage < BasePage
  path '/#/saved-payment-methods'
end

class ForgotPasswordPage < BasePage
  path '/#/forgot-password'

  def find_account(email)
    fill_in(Locators::FORGOT_EMAIL, with: email)
    # The question is fetched after the change event, and the answer field starts
    # disabled, so waiting for an enabled field is the readiness check.
    find_field(Locators::SECURITY_ANSWER, disabled: false, wait: 10)
    self
  end

  # The matched account's question is shown as the answer field's placeholder.
  def security_question = find("##{Locators::SECURITY_ANSWER}", wait: 10)[:placeholder]

  def reset(answer:, new_password:, repeat: new_password)
    fill_in(Locators::SECURITY_ANSWER, with: answer)
    fill_in(Locators::NEW_PASSWORD, with: new_password)
    fill_in(Locators::NEW_PASSWORD_REPEAT, with: repeat)
    self
  end

  def submit
    click_button(Locators::RESET)
    self
  end

  def submit_enabled? = enabled?(Locators::RESET)
end
