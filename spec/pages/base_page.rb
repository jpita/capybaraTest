# frozen_string_literal: true

class BasePage
  include Capybara::DSL

  # Anonymous users get this panel instead of a redirect, so the URL stays put.
  FORBIDDEN_TEXT = 'You are not allowed to access this page!'

  # A LoginGuard route uses a different panel from a role-guarded one, so the two
  # cases are checked separately rather than treating one message as both.
  LOGIN_REQUIRED_TEXT = 'Please login to view this page'

  # Shown by both password forms until the two entries match.
  PASSWORD_MISMATCH_TEXT = 'Passwords do not match'

  # Subclasses declare their route once and inherit `open`.
  def self.path(value) = define_method(:path) { value }

  def open
    visit(path)
    dismiss_overlays
    self
  end

  # The app routes on the client and a hash route change does not reload the
  # document, so the next component only renders after the click returns. Waiting on
  # the route is what shows the step actually advanced, rather than reading the
  # previous page and finding it empty.
  def wait_until_open(wait: Capybara.default_max_wait_time)
    deadline = Time.now + wait
    until page.current_url.include?(path)
      raise "#{self.class} did not open, url is #{page.current_url}" if Time.now > deadline

      sleep 0.05
    end
    self
  end

  # Juice Shop opens behind a cookie bar and a welcome dialog. Both cover the app,
  # so every page dismisses them before it does anything else.
  # The welcome dialog's backdrop sits above the cookie bar, so it must close first
  # or its overlay intercepts the cookie bar's click.
  def dismiss_overlays
    click_button(Locators::WELCOME_CLOSE) if has_button?(Locators::WELCOME_CLOSE, wait: 5)
    dismiss_cookie_bar
    self
  end

  # The consent bar floats over the bottom right, which is where the paginator
  # sits once the driver scrolls it into view. Its dismiss control is an <a> with
  # no href, so the link locator never matches it and it is matched by class.
  # Dismissing leaves the container in the DOM at zero height, so waiting for the
  # class to disappear would hang; the click itself is the point of no return.
  def dismiss_cookie_bar
    find(Locators::COOKIE_DISMISS, wait: 2).click if has_css?(Locators::COOKIE_DISMISS, wait: 2)
    self
  end

  def forbidden? = has_text?(FORBIDDEN_TEXT, wait: 5)

  def login_required? = has_text?(LOGIN_REQUIRED_TEXT, wait: 5)

  # The register and change-password forms both show this error under the repeat
  # field, so it is defined once here.
  def mismatch_error? = has_text?(PASSWORD_MISMATCH_TEXT, wait: 5)

  # Some flows confirm inline with a .confirmation element instead of a snackbar, and
  # it stays hidden until the component clears the form it belongs to.
  def has_confirmation?(text) = has_css?(Locators::CONFIRMATION, text: text, wait: 10)

  # A solved-challenge banner renders as an extra mat-card and its toast covers
  # the page, so both are cleared before a page is used.
  def dismiss_notifications
    click_button(Locators::CHALLENGE_CLOSE) while has_button?(Locators::CHALLENGE_CLOSE, wait: 1)
    within(Locators::SNACKBAR) { click_button(Locators::SNACKBAR_CLOSE) } while has_css?(Locators::SNACKBAR, wait: 1)
    self
  end

  # MatSnackBar shows one message at a time, and the app posts its own 5 second
  # "language has been changed" notice whenever it loads without a language cookie.
  # The harness clears cookies between examples, so that notice can replace the
  # confirmation under test. Waiting for the expected text makes the check about the
  # app's own response rather than whatever snackbar happens to be on screen.
  def has_toast?(text) = has_css?(Locators::SNACKBAR, text: text, wait: 10)

  def basket_count = find(Locators::CART, wait: 10).text[/\d+/].to_i

  def open_account_menu
    click_button(Locators::ACCOUNT_MENU)
    self
  end

  # The menu renders synchronously on click, so a short wait avoids waiting out
  # the full default timeout when the expected item never appears.
  def signed_in?
    open_account_menu
    signed_in = has_css?(Locators::LOGOUT_SELECTOR, wait: 1)
    close_menu
    signed_in
  end

  def log_out
    open_account_menu
    click_button(Locators::LOGOUT)
    self
  end

  # An open menu traps later clicks behind a transparent backdrop.
  def close_menu
    find(Locators::BODY).send_keys(:escape)
    self
  end

  # Material disables a control two ways: a [disabled] binding sets the attribute and
  # the property, while disabledInteractive sets only aria-disabled="true". Reading
  # the attribute alone is unreliable, because for a boolean attribute Selenium falls
  # back to the DOM property and returns the string "false" for an enabled control,
  # which is truthy. The driver's disabled? reads the property itself, so the two
  # reads together cover both mechanisms.
  def enabled?(label)
    control = find_button(label, disabled: :all)
    !control.disabled? && control['aria-disabled'] != 'true'
  end
end
