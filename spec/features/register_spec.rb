# frozen_string_literal: true

RSpec.feature 'Registration', type: :feature do
  let(:email) { "capybara-#{SecureRandom.hex(6)}@example.test" }
  let(:password) { 'Passw0rd!23' }

  scenario 'a new customer registers and can then sign in with those details' do
    register = RegisterPage.new.open
    question = register.first_security_question
    register.register(email: email, password: password, answer: 'test answer')
    expect(register.submit_enabled?).to be(true), "expected Register to be enabled for question #{question}"
    register.submit

    login = LoginPage.new.open.sign_in(email: email, password: password)

    expect(login).to be_signed_in
  end

  scenario 'the form refuses to submit while the passwords differ' do
    register = RegisterPage.new.open
    register.first_security_question
    register.register(email: email, password: password, repeat_password: 'something-else', answer: 'test answer')

    expect(register).to be_mismatch_error
    expect(register.submit_enabled?).to be(false)
  end

  scenario 'the form refuses to submit without a security question' do
    register = RegisterPage.new.open
    register.register(email: email, password: password, answer: 'test answer')

    # Everything but the question is filled, so the question is what holds it back.
    expect(register.submit_enabled?).to be(false)
  end

  scenario 'a password below the minimum length is rejected' do
    register = RegisterPage.new.open
    register.first_security_question
    register.register(email: email, password: 'abc', answer: 'test answer')

    expect(register).to be_password_advice_visible
    expect(register.submit_enabled?).to be(false)
  end

  scenario 'an email that is already registered cannot be registered twice' do
    account = register_account

    register = RegisterPage.new.open
    register.first_security_question
    register.register(email: account.email, password: password, answer: 'test answer')
    register.submit

    # The account already exists, so the app must not sign the visitor in.
    expect(page).to have_current_path(%r{#/register}, url: true)
  end
end
