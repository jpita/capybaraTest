# frozen_string_literal: true

class RegisterPage < BasePage
  path '/#/register'

  def register(email:, password:, repeat_password: password, question: nil, answer: 'test answer')
    fill_in(Locators::REGISTER_EMAIL, with: email) if email
    fill_in(Locators::REGISTER_PASSWORD, with: password) if password
    fill_in(Locators::REGISTER_REPEAT, with: repeat_password) if repeat_password
    choose_security_question(question) if question
    fill_in(Locators::REGISTER_ANSWER, with: answer) if answer
    self
  end

  def submit
    click_button(Locators::REGISTER_BUTTON)
    self
  end

  # The question list arrives from the API after the form renders, so the select can
  # be clicked while it is still empty.
  def choose_security_question(question)
    open_select(Locators::SECURITY_QUESTION_SELECT)
    find(Locators::OPTION, text: question, match: :prefer_exact).click
    self
  end

  def first_security_question
    open_select(Locators::SECURITY_QUESTION_SELECT)
    text = all(Locators::OPTION, minimum: 1).first.text
    find(Locators::OPTION, text: text, match: :prefer_exact).click
    text
  end

  def submit_enabled? = enabled?(Locators::REGISTER_BUTTON)

  def password_advice_visible?
    has_text?('Password must be 5-40 characters long.', wait: 5)
  end
end
