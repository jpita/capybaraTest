# frozen_string_literal: true

RSpec.feature 'Authorization', type: :feature do
  # Juice Shop keeps the URL and swaps the body for a 403 panel, so the check
  # is on what the page shows rather than where it navigated.
  context 'as an anonymous visitor' do
    it 'blocks the administration page' do
      expect(AdministrationPage.new.open).to be_forbidden
    end

    it 'blocks the accounting page' do
      expect(AccountingPage.new.open).to be_forbidden
    end

    it 'allows saved addresses to load without a session' do
      expect(SavedAddressesPage.new.open).not_to be_forbidden
    end

    it 'allows saved payment methods to load without a session' do
      expect(SavedPaymentMethodsPage.new.open).not_to be_forbidden
    end

    it 'allows the deluxe membership page to load without a session' do
      expect(DeluxeMembershipPage.new.open).not_to be_forbidden
    end

    it 'allows the data export page to load without a session' do
      expect(DataExportPage.new.open).not_to be_forbidden
    end

    it 'allows two factor setup to load without a session' do
      expect(TwoFactorAuthPage.new.open).not_to be_forbidden
    end
  end

  context 'as a signed in customer' do
    let(:account) { register_account }

    before { sign_in_as(account) }

    it 'still blocks the administration page' do
      expect(AdministrationPage.new.open).to be_forbidden
    end

    it 'still blocks the accounting page' do
      expect(AccountingPage.new.open).to be_forbidden
    end

    it 'allows saved addresses' do
      expect(SavedAddressesPage.new.open).not_to be_forbidden
    end

    it 'allows the order history' do
      expect(OrderHistoryPage.new.open).not_to be_forbidden
    end
  end

  context 'pages that need no account' do
    it 'serves the privacy policy' do
      expect(PrivacyPolicyPage.new.open).not_to be_forbidden
    end

    it 'serves the contact form' do
      expect(ContactPage.new.open).not_to be_forbidden
    end
  end
end
