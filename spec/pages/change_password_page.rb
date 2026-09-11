# frozen_string_literal: true

class ChangePasswordPage < BasePage
  path '/#/privacy-security/change-password'

  def change(current:, new_password:, repeat: new_password)
    fill_in(Locators::CURRENT_PASSWORD, with: current)
    fill_in(Locators::NEW_PASSWORD, with: new_password)
    fill_in(Locators::NEW_PASSWORD_REPEAT, with: repeat)
    # Material renders a mat-error only for a touched control, and typing leaves it
    # dirty but untouched, so the last field is blurred to bring the error up.
    find(Locators::CHANGE_PASSWORD_REPEAT_FIELD).send_keys(:tab)
    self
  end

  def submit
    click_button(Locators::CHANGE_PASSWORD_BUTTON)
    self
  end

  def submit_enabled? = enabled?(Locators::CHANGE_PASSWORD_BUTTON)
end
