# frozen_string_literal: true

class BasketPage < BasePage
  path '/#/basket'

  def rows = all(Locators::ROW, minimum: 0)

  def product_names = rows.map { |row| row.find(Locators::BASKET_PRODUCT_CELL).text }

  def total_price = find(Locators::BASKET_TOTAL, wait: 10).text[/[\d.]+/].to_f

  def empty? = has_no_css?(Locators::ROW, wait: 5)

  def quantity_of(product) = row_for(product).find(Locators::BASKET_QUANTITY).text.to_i

  # The quantity and delete controls are icon-only buttons with no id or label,
  # so they are addressed by the icon they render.
  def increase(product) = change_quantity(product, Locators::ICON_INCREASE)
  def decrease(product) = change_quantity(product, Locators::ICON_DECREASE)

  def remove(product)
    click_icon(product, Locators::ICON_REMOVE)
    has_no_css?(Locators::ROW, text: product, wait: 10)
    self
  end

  def contains?(product) = has_css?(Locators::ROW, text: product, wait: 5)
  def excludes?(product) = has_no_css?(Locators::ROW, text: product, wait: 10)

  def checkout
    click_button(Locators::CHECKOUT)
    AddressSelectPage.new.wait_until_open
  end

  private

  def row_for(product) = find(Locators::ROW, text: product, wait: 10)

  # Font Awesome swaps each <i class="fas fa-x"> for an <svg data-icon="x">,
  # so both forms are matched to stay stable mid-swap.
  def click_icon(product, icon)
    row_for(product).find(format(Locators::ICON_BUTTON, icon: icon)).click
    self
  end

  # The app re-reads the basket over several round trips after a quantity
  # change, so the row still shows the old number when the click returns.
  def change_quantity(product, icon)
    before = quantity_of(product)
    click_icon(product, icon)

    deadline = Time.now + Capybara.default_max_wait_time
    loop do
      return self if quantity_of(product) != before
      raise "#{product} stayed at #{before} after clicking #{icon}" if Time.now > deadline

      sleep 0.05
    end
  end
end
