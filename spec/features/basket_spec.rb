# frozen_string_literal: true

RSpec.feature 'Basket', type: :feature do
  let(:account) { register_account }

  before { sign_in_as(account) }

  scenario 'a product added from the shop appears in the basket' do
    search = SearchPage.new.open
    product = search.add_first_to_basket

    basket = BasketPage.new.open

    expect(basket).to be_contains(product)
    expect(basket.quantity_of(product)).to eq(1)
  end

  scenario 'the navbar count follows what is in the basket' do
    search = SearchPage.new.open
    expect(search.basket_count).to eq(0)

    search.add_first_to_basket

    expect(SearchPage.new.open.basket_count).to eq(1)
  end

  scenario 'increasing the quantity raises the line and the total' do
    search = SearchPage.new.open
    product = search.add_first_to_basket

    basket = BasketPage.new.open
    unit_price = basket.total_price
    basket.increase(product)

    expect(basket.quantity_of(product)).to eq(2)
    expect(basket.total_price).to eq((unit_price * 2).round(2))
  end

  scenario 'decreasing the quantity lowers the line again' do
    search = SearchPage.new.open
    product = search.add_first_to_basket

    basket = BasketPage.new.open
    basket.increase(product)
    expect(basket.quantity_of(product)).to eq(2)

    basket.decrease(product)

    expect(basket.quantity_of(product)).to eq(1)
  end

  scenario 'removing the only product empties the basket' do
    search = SearchPage.new.open
    product = search.add_first_to_basket

    basket = BasketPage.new.open.remove(product)

    expect(basket).to be_excludes(product)
    expect(basket).to be_empty
  end

  scenario 'the basket holds several different products at once' do
    names = product_names(limit: 2)
    search = SearchPage.new.open
    names.each { |name| search.add_to_basket(name) }

    basket = BasketPage.new.open

    names.each { |name| expect(basket).to be_contains(name) }
  end

  scenario 'a new customer starts with an empty basket' do
    basket = BasketPage.new.open

    expect(basket).to be_empty
    expect(basket.basket_count).to eq(0)
  end
end
