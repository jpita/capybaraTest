# frozen_string_literal: true

RSpec.feature 'Product catalogue', type: :feature do
  scenario 'the first page shows a full page of products out of the whole catalogue' do
    search = SearchPage.new.open

    expect(search.result_count).to eq(search.shown_count)
    expect(search.total_results).to eq(total_product_count)
  end

  scenario 'paging forward shows a different set of products' do
    search = SearchPage.new.open
    first_page = search.result_names
    page_size = search.shown_count

    search.next_page

    expect(search.result_names).not_to eq(first_page)
    expect(search.range_label).to start_with((page_size + 1).to_s)
  end

  scenario 'paging back returns to the products seen first' do
    search = SearchPage.new.open
    first_page = search.result_names

    search.next_page.previous_page

    expect(search.result_names).to eq(first_page)
  end

  scenario 'the first page cannot page back and the last cannot page forward' do
    search = SearchPage.new.open

    expect(search.previous_page_enabled?).to be(false)
    expect(search.next_page_enabled?).to be(true)
  end

  scenario 'asking for more per page shows more products' do
    search = SearchPage.new.open
    first_page = search.result_count
    larger_page = search.page_size_options.last

    search.items_per_page(larger_page)

    expect(search.result_count).to be > first_page
  end

  scenario 'a product opens its own details' do
    name = first_product_name

    dialog = SearchPage.new.open.open_details(name)

    expect(dialog).to be_open
    expect(dialog.title).to eq(name)
  end

  scenario 'closing the details returns to the catalogue' do
    name = first_product_name
    search = SearchPage.new.open

    search.open_details(name).close

    expect(search.result_count).to eq(search.shown_count)
  end

  scenario 'a search for a term with no match shows the empty state' do
    search = SearchPage.new.open.search_for('nosuchproduct-zzz')

    expect(search).to be_no_results
    expect(search.result_names).to be_empty
  end

  scenario 'a search ignores surrounding whitespace' do
    name = first_product_name

    search = SearchPage.new.open.search_for("  #{name}  ")

    expect(search.result_names).to include(name)
  end

  scenario 'a search for punctuation only returns no products rather than erroring' do
    search = SearchPage.new.open.search_for('!!!')

    expect(search.result_names).to be_empty
  end
end
