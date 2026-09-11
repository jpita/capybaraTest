# frozen_string_literal: true

class SearchPage < BasePage
  path '/#/search'

  def search_for(term)
    find(Locators::SEARCH_TOGGLE).click
    find(Locators::SEARCH_INPUT).set("#{term}\n")
    self
  end

  def result_names = all(Locators::PRODUCT_NAME, minimum: 0).map(&:text)
  def no_results? = has_text?('No results found')
  def result_count = all(Locators::PRODUCT_NAME, minimum: 0).size

  def add_to_basket(product)
    find(Locators::PRODUCT_CARD, text: product, wait: 10).click_button(Locators::ADD_TO_BASKET)
    confirm_added(product)
    self
  end

  def add_first_to_basket
    card = all(Locators::PRODUCT_CARD, minimum: 1).first
    name = card.find(Locators::PRODUCT_NAME_TEXT).text
    card.click_button(Locators::ADD_TO_BASKET)
    confirm_added(name)
    name
  end

  def open_details(product)
    find(Locators::PRODUCT_CARD, text: product, wait: 10).find(Locators::PRODUCT_NAME_TEXT).click
    ProductDialog.new
  end

  # Reads "1 – 16 of 46", which is the only place the total is shown.
  def range_label = find(Locators::PAGINATOR_RANGE, wait: 10).text
  def total_results = range_label[/of (\d+)/, 1].to_i

  # The app sizes a page as Math.ceil(15 / columns) * columns, so how many
  # products appear follows the viewport width and is never a constant.
  def shown_count
    first, last = range_label.scan(/\d+/).first(2).map(&:to_i)
    last - first + 1
  end

  def next_page
    click_button(Locators::NEXT_PAGE)
    self
  end

  def previous_page
    click_button(Locators::PREVIOUS_PAGE)
    self
  end

  # The paginator buttons stay focusable when disabled, so they carry
  # aria-disabled instead of the disabled attribute. enabled? reads both.
  def next_page_enabled? = enabled?(Locators::NEXT_PAGE)
  def previous_page_enabled? = enabled?(Locators::PREVIOUS_PAGE)

  # The page size select is covered by the paginator's touch target, which is the
  # element that receives the tap.
  def items_per_page(size)
    open_page_size_menu
    find(Locators::OPTION, text: size.to_s, exact_text: true).click
    self
  end

  # The paginator offers only multiples of the current page size, which follows the
  # viewport width, so the sizes on offer are read rather than assumed.
  def page_size_options
    open_page_size_menu
    sizes = all(Locators::OPTION, minimum: 1).map { |option| option.text.to_i }
    find(Locators::BODY).send_keys(:escape)
    sizes
  end

  private

  # The basket item is posted in the background, so a page opened straight after
  # the click can finish loading before the item exists. The toast only renders
  # once the post has succeeded, so it is the point to wait for.
  def confirm_added(product)
    has_css?(Locators::SNACKBAR, text: product, wait: 5)
  end

  def open_page_size_menu
    find(Locators::PAGINATOR_TOUCH_TARGET).click
    self
  end
end

class ProductDialog < BasePage
  def open? = has_css?(Locators::DIALOG, wait: 10)
  def title = find("#{Locators::DIALOG} h1, #{Locators::DIALOG} h2", wait: 10).text
  def text = find(Locators::DIALOG, wait: 10).text

  def close
    within(Locators::DIALOG) { click_button(Locators::DIALOG_CLOSE) }
    self
  end
end
