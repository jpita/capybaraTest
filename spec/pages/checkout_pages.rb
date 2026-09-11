# frozen_string_literal: true

# The four checkout steps share the same shape: pick a row, then continue.
# Each step returns the next page so a spec reads as one chain.
class CheckoutStepPage < BasePage
  def self.continue_label(value) = define_method(:continue_label) { value }

  def select_row(text)
    find(Locators::ROW, text: text, wait: 10).find(Locators::RADIO, visible: :all).click
    self
  end

  def select_first_row
    all(Locators::ROW, minimum: 1).first.find(Locators::RADIO, visible: :all).click
    self
  end

  def continue_enabled? = enabled?(continue_label)

  def continue
    click_button(continue_label)
    next_page.wait_until_open
  end

  private

  # Cells render an icon then &nbsp; then the value. Ruby does not treat a
  # non-breaking space as whitespace, so it survives strip and breaks comparisons.
  def cell_text(row, column)
    row.find(format(Locators::CELL, column: column)).text.gsub("\u00A0", ' ').strip
  end
end

class AddressSelectPage < CheckoutStepPage
  path '/#/address/select'
  continue_label Locators::PROCEED_TO_PAYMENT

  def names = all(Locators::ROW, minimum: 0).map { |row| cell_text(row, 'Name') }

  def add_new_address
    click_button(Locators::ADD_ADDRESS)
    AddressCreatePage.new
  end

  private

  def next_page = DeliveryMethodPage.new
end

class AddressCreatePage < BasePage
  path '/#/address/create'

  # These inputs carry generated ids and no aria-label, so the floating label
  # text is the only stable handle.
  def fill_address(country: 'Testland', name: 'Test Person', mobile: '1234567890',
                   zip: '12345', address: '1 Test Street', city: 'Testville', state: 'Teststate')
    fill_in(Locators::ADDRESS_COUNTRY, with: country)
    fill_in(Locators::ADDRESS_NAME, with: name)
    fill_in(Locators::ADDRESS_MOBILE, with: mobile)
    fill_in(Locators::ADDRESS_ZIP, with: zip)
    fill_in(Locators::ADDRESS_STREET, with: address)
    fill_in(Locators::ADDRESS_CITY, with: city)
    fill_in(Locators::ADDRESS_STATE, with: state)
    self
  end

  def submit_enabled? = enabled?(Locators::SUBMIT_BUTTON)

  def submit
    click_button(Locators::SUBMIT_BUTTON)
    AddressSelectPage.new.wait_until_open
  end
end

class DeliveryMethodPage < CheckoutStepPage
  path '/#/delivery-method'
  continue_label Locators::PROCEED_TO_DELIVERY

  # The table is fetched after the route changes, so a read taken straight after the
  # previous step can come back empty. minimum makes the read wait for the rows.
  def speeds = all(Locators::ROW, minimum: 1).map { |row| cell_text(row, 'Name') }

  def price_of(speed)
    find(Locators::ROW, text: speed, wait: 10).find(Locators::DELIVERY_PRICE_CELL).text[/[\d.]+/].to_f
  end

  private

  def next_page = PaymentPage.new
end

class PaymentPage < CheckoutStepPage
  path '/#/payment/shop'
  continue_label Locators::PROCEED_TO_REVIEW

  # A card is created for the account before the flow starts, so waiting for one
  # makes the read deterministic instead of racing the page render.
  def card_numbers = all(Locators::ROW, minimum: 1).map { |row| row.find(Locators::CARD_NUMBER_CELL).text }

  private

  def next_page = OrderSummaryPage.new
end

class OrderSummaryPage < BasePage
  path '/#/order-summary'

  def items_total = price_for('Items')
  def delivery_total = price_for('Delivery')
  def promotion_total = price_for('Promotion')
  def order_total = price_for('Total Price')

  # The summary embeds the basket component, which fetches its rows after the route
  # changes, so the read waits for them instead of racing the render.
  def product_names = all(Locators::ROW, minimum: 1).map { |row| row.find(Locators::BASKET_PRODUCT_CELL).text }

  def quantity_of(product) = find(Locators::ROW, text: product, wait: 10).find(Locators::BASKET_QUANTITY_CELL).text.to_i

  def place_order
    click_button(Locators::COMPLETE_PURCHASE)
    OrderCompletionPage.new.wait_until_open
  end

  private

  # The totals live in a plain table, not the mat-row grid the basket uses.
  def price_for(label)
    find(Locators::PLAIN_ROW, text: label, wait: 10).find(Locators::SUMMARY_PRICE).text[/[\d.]+/].to_f
  end
end

class OrderCompletionPage < BasePage
  # The id is appended to this route, so the check is a prefix match.
  path '/#/order-completion'

  def confirmed? = has_text?('Thank you for your purchase!', wait: 15)

  # The id is only in the URL, which is what the Track Orders link is built from.
  def order_id = current_url[%r{order-completion/([^?]+)}, 1]

  def delivery_days = find(Locators::DELIVERY_TEXT, wait: 10).text[/delivered in (\d+) days/, 1].to_i

  def product_names = all(Locators::TABLE_ROW, minimum: 0).map(&:text).join("\n")
end
