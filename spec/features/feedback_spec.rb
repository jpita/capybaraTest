# frozen_string_literal: true

RSpec.feature 'Customer feedback', type: :feature do
  let(:account) { register_account }

  scenario 'a customer leaves feedback and the app confirms it' do
    sign_in_as(account)

    contact = ContactPage.new.open
    contact.leave_feedback(comment: "Great juice #{SecureRandom.hex(4)}", rating: 5).submit

    expect(contact).to have_toast('Thank you')
  end

  scenario 'feedback will not submit without solving the CAPTCHA' do
    sign_in_as(account)

    contact = ContactPage.new.open
    fill_in('comment', with: 'No captcha answer here')

    expect(contact.submit_enabled?).to be(false)
  end

  scenario 'feedback will not submit without a comment' do
    sign_in_as(account)

    contact = ContactPage.new.open
    contact.solve_captcha

    expect(contact.submit_enabled?).to be(false)
  end

  scenario 'a signed in customer cannot post feedback under another name' do
    sign_in_as(account)

    expect(ContactPage.new.open).to be_author_locked
  end

  scenario 'the comment field states and enforces its limit' do
    sign_in_as(account)

    expect(ContactPage.new.open.comment_limit).to eq(160)
  end

  scenario 'a customer files a complaint and the app confirms it' do
    sign_in_as(account)

    complain = ComplainPage.new.open
    complain.file_complaint(message: "This juice arrived warm #{SecureRandom.hex(4)}").submit

    expect(complain).to have_confirmation('Customer support will get in touch')
  end

  scenario 'a complaint will not submit while it is empty' do
    sign_in_as(account)

    expect(ComplainPage.new.open.submit_enabled?).to be(false)
  end

  scenario 'a complaint is filed under the signed in customer' do
    sign_in_as(account)

    expect(ComplainPage.new.open).to be_customer_locked
  end
end
