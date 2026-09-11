# frozen_string_literal: true

RSpec.feature 'Login', type: :feature do
  scenario 'a registered customer signs in and lands on the shop' do
    account = register_account

    login = LoginPage.new.open.sign_in(email: account.email, password: account.password)

    expect(login).to be_signed_in
    expect(page).to have_current_path(%r{#/search}, url: true)
  end

  scenario 'a wrong password is rejected and the customer stays signed out' do
    account = register_account

    login = LoginPage.new.open.sign_in(email: account.email, password: 'not-the-password')

    expect(login.error_message).to eq('Invalid email or password.')
    expect(login).not_to be_signed_in
  end

  scenario 'an unknown email fails with the same message as a wrong password' do
    login = LoginPage.new.open.sign_in(email: 'nobody-here@example.test', password: 'Passw0rd!23')

    # Both failures must read the same, or the form tells an attacker which emails exist.
    expect(login.error_message).to eq('Invalid email or password.')
  end
end
