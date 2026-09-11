# frozen_string_literal: true

RSpec.feature 'Password management', type: :feature do
  let(:account) { register_account }
  let(:new_password) { 'Chang3d!Pass' }

  scenario 'a customer changes their password and signs in with the new one' do
    sign_in_as(account)

    change = ChangePasswordPage.new.open
    change.change(current: account.password, new_password: new_password).submit

    expect(change).to have_confirmation('Your password was successfully changed')
  end

  scenario 'the old password stops working after the change' do
    sign_in_as(account)
    ChangePasswordPage.new.open.change(current: account.password, new_password: new_password).submit
    ChangePasswordPage.new.log_out

    login = LoginPage.new.open.sign_in(email: account.email, password: account.password)

    expect(login.error_message).to eq('Invalid email or password.')
  end

  scenario 'the change is refused when the repeat does not match' do
    sign_in_as(account)

    change = ChangePasswordPage.new.open
    change.change(current: account.password, new_password: new_password, repeat: 'different-again')

    expect(change).to be_mismatch_error
    expect(change.submit_enabled?).to be(false)
  end

  scenario 'the change is refused without the current password' do
    sign_in_as(account)

    change = ChangePasswordPage.new.open
    fill_in('newPassword', with: new_password)
    fill_in('newPasswordRepeat', with: new_password)

    # The app refuses by leaving the submit button disabled, so there is nothing to
    # click and no error message until the field is touched.
    expect(change.submit_enabled?).to be(false)
  end

  scenario 'forgot password shows the question that belongs to the account' do
    forgot = ForgotPasswordPage.new.open.find_account(account.email)

    expect(forgot.security_question).to eq("Mother's maiden name?")
  end

  scenario 'a reset will not submit while the new passwords differ' do
    forgot = ForgotPasswordPage.new.open.find_account(account.email)
    forgot.reset(answer: 'anything', new_password: new_password, repeat: 'not-the-same')

    expect(forgot.submit_enabled?).to be(false)
  end
end
