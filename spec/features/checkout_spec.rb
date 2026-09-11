# frozen_string_literal: true

RSpec.feature 'Checkout', type: :feature do
  let(:account) { register_account }

  before do
    token = sign_in_as(account)
    add_payment_method(token)
    @product = SearchPage.new.open.add_first_to_basket
  end

  # A new account has no address or card, so both are created on the way through.
  def checkout_to_payment
    address = BasketPage.new.open.checkout
    address.add_new_address.fill_address.submit
    address.select_first_row.continue
           .select_row('Standard Delivery').continue
  end

  scenario 'a customer places an order and lands on the confirmation' do
    payment = checkout_to_payment
    summary = payment.select_first_row.continue

    completion = summary.place_order

    expect(completion).to be_confirmed
    expect(completion.order_id).not_to be_nil
  end

  scenario 'the order summary repeats the basket and its totals' do
    checkout_to_payment
    PaymentPage.new.select_first_row.continue

    summary = OrderSummaryPage.new

    expect(summary.product_names).to include(@product)
    expect(summary.order_total).to eq((summary.items_total + summary.delivery_total - summary.promotion_total).round(2))
  end

  scenario 'standard delivery adds nothing to the order total' do
    checkout_to_payment
    PaymentPage.new.select_first_row.continue

    summary = OrderSummaryPage.new

    expect(summary.delivery_total).to eq(0.0)
    expect(summary.order_total).to eq(summary.items_total)
  end

  scenario 'the basket is emptied once the order is placed' do
    checkout_to_payment
    PaymentPage.new.select_first_row.continue
    OrderSummaryPage.new.place_order

    basket = BasketPage.new.open

    expect(basket).to be_empty
    expect(basket.basket_count).to eq(0)
  end

  scenario 'the placed order shows up in the order history' do
    checkout_to_payment
    PaymentPage.new.select_first_row.continue
    order_id = OrderSummaryPage.new.place_order.order_id

    history = OrderHistoryPage.new.open

    expect(history).to be_contains_order(order_id)
  end

  scenario 'checkout will not continue until an address is chosen' do
    address = BasketPage.new.open.checkout
    address.add_new_address.fill_address.submit

    expect(address.continue_enabled?).to be(false)

    address.select_first_row

    expect(address.continue_enabled?).to be(true)
  end

  scenario 'checkout will not continue until a delivery speed is chosen' do
    address = BasketPage.new.open.checkout
    address.add_new_address.fill_address.submit
    delivery = address.select_first_row.continue

    expect(delivery.continue_enabled?).to be(false)

    delivery.select_row('Standard Delivery')

    expect(delivery.continue_enabled?).to be(true)
  end

  scenario 'the three delivery speeds are offered in price order' do
    address = BasketPage.new.open.checkout
    address.add_new_address.fill_address.submit
    delivery = address.select_first_row.continue

    expect(delivery.speeds).to contain_exactly('One Day Delivery', 'Fast Delivery', 'Standard Delivery')
    expect(delivery.price_of('Standard Delivery')).to be < delivery.price_of('One Day Delivery')
  end

  scenario 'a faster delivery costs more than the standard one' do
    checkout_to_payment
    PaymentPage.new.select_first_row.continue
    standard_total = OrderSummaryPage.new.order_total

    # Start again and take the quickest option instead.
    SearchPage.new.open.add_to_basket(@product)
    address = BasketPage.new.open.checkout
    address.select_first_row.continue.select_row('One Day Delivery').continue
    PaymentPage.new.select_first_row.continue

    expect(OrderSummaryPage.new.order_total).to be > standard_total
  end
end
