# frozen_string_literal: true

RSpec.feature 'Product search', type: :feature do
  scenario 'searching for a product that exists lists it' do
    product = first_product_name

    results = SearchPage.new.open.search_for(product).result_names

    expect(results).to include(product)
  end

  scenario 'a search with no matches shows the empty state and no products' do
    search = SearchPage.new.open.search_for('nosuchproduct-zzz')

    expect(search).to be_no_results
    expect(search.result_names).to be_empty
  end
end
