# Juice Shop end to end tests

Capybara and RSpec driving a real browser against OWASP Juice Shop.

## What the suite demonstrates

68 scenarios across 10 feature files.

It found three real defects in the app, all fixed here:

- `frontend/src/app/Services/basket.service.ts:67` read `.Products` on a null basket, so the basket badge threw.
- `frontend/src/app/product/product.component.ts:74` did the same, so Add to Basket threw.
- `frontend/src/app/purchase-basket/purchase-basket.component.ts:80` did the same, so the basket page threw.

`routes/basket.ts` answers `{ status: 'success', data: null }` when an account has no basket row, and all three sites trusted that payload. Each now falls back to an empty array. Details and the exact patch are in `app/ATTRIBUTION.md`.

## Run it

```
cd app && npm install --legacy-peer-deps
cd .. && bundle install
bundle exec rspec
```

Needs Node 22.22.3 or newer, and Chrome. The first command also builds the app, so the second run is instant.

`bundle exec rspec` is the whole story. Setup and teardown are wired in, so there is no server to remember to start.

## What is under test

`app/` is OWASP Juice Shop at the commit recorded in `app/ATTRIBUTION.md`, vendored so the suite runs from source with no network and no Docker.

The app's own test suites were removed. This suite is the only one that runs.

| Spec | Covers |
| --- | --- |
| `authorization_spec.rb` | Which pages load for an anonymous visitor, and which stay blocked for a signed in customer |
| `basket_spec.rb` | Add, increase, decrease, remove, and the navbar count that follows the basket |
| `checkout_spec.rb` | The four step checkout, delivery pricing, order history, and what blocks each step |
| `feedback_spec.rb` | Customer feedback, the CAPTCHA, the comment limit, and complaints |
| `login_spec.rb` | Sign in, a wrong password, and an unknown email |
| `password_spec.rb` | Change password, the mismatch and current password rules, and forgot password |
| `product_spec.rb` | Paging through the catalogue, page size, product details, and search edge cases |
| `register_spec.rb` | Registration, and each rule that stops the form submitting |
| `search_spec.rb` | A search that matches and one that does not |
| `session_spec.rb` | Log out, remember me, reload survival, and the basket following the session |

## How it is built

Three layers, each with one job.

- `spec/features/` reads like English. A spec drives pages and asserts, and never names a selector.
- `spec/pages/` is one class per screen, all inheriting `BasePage`. Each class declares its route once with `path` and inherits `open`, which visits it and dismisses the cookie bar and welcome banner.
- `spec/support/locators.rb` holds every selector, id and label the suite uses. One change there moves every caller.

Shared waits live in `BasePage`, so no spec sleeps:

- `enabled?` reads both disable mechanisms. A `[disabled]` binding sets the property, and `disabledInteractive` sets only `aria-disabled="true"`. Reading the attribute alone fails, because Selenium falls back to the property and returns the string `"false"`, which is truthy.
- `has_toast?` and `has_confirmation?` wait for the app's own confirmation, so a check reads the app's response rather than whatever snackbar happens to be on screen.
- `wait_until_open` waits on the route, because a hash route change does not reload the document.

## Data between runs

The app wipes and reseeds its database on every start: `app/server.ts` calls `sequelize.sync({ force: true })` and then `datacreator()` before it listens. `spec_helper.rb` restarts the app before the suite and again after it, so a run starts from seeded data and leaves no account, order or challenge behind.

`bin/app` drives the app by hand:

```
bin/app start | stop | restart | status
```

`rake app:setup`, `rake app:reset` and `rake` wrap the same things.

## Adding a page

1. Add the selectors to `spec/support/locators.rb`.
2. Add a class to `spec/pages/`:

```ruby
class OrderHistoryPage < BasePage
  path '/#/order-history'

  def order_ids = all(Locators::ORDER_HEADING, minimum: 0).map { |card| card.text[/#(\S+)/, 1] }
end
```

3. Use it from a spec: `OrderHistoryPage.new.open.order_ids`.

## Attribution

`app/` is MIT licensed. See `app/ATTRIBUTION.md` for the upstream project, the exact commit, and every change made to it.