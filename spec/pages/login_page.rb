# frozen_string_literal: true

class LoginPage < BasePage
  path '/#/login'

  def sign_in(email:, password:)
    fill_in(Locators::LOGIN_EMAIL, with: email)
    fill_in(Locators::LOGIN_PASSWORD, with: password)
    # By id, not by text: the Material icon ligature makes the label read
    # "exit_to_app Log in", and "Log in" also matches the Google button.
    click_button(Locators::LOGIN_BUTTON)
    self
  end

  def error_message = find(Locators::ERROR).text

  def remember_me
    check(Locators::REMEMBER_ME, allow_label_click: true)
    self
  end
end
