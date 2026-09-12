# frozen_string_literal: true

# Every string the suite uses to find an element lives here, so a change to the
# app's markup or labels is a one line edit. Copy that a page asserts on stays
# with that page.
#
# Callers differ in what they accept. find, all and has_css? take CSS. click_button,
# click_link, fill_in and find_field take a locator, which is an id, name, label or
# text, and not CSS. Where an element needs both, both forms are listed.
module Locators
  # Shared chrome
  SNACKBAR = 'simple-snack-bar'
  SNACKBAR_CLOSE = 'X'
  CONFIRMATION = '.confirmation'
  WELCOME_CLOSE = 'Close Welcome Banner'
  COOKIE_DISMISS = '.cc-btn.cc-dismiss'
  # Either overlay in one query, so a page pays for one probe instead of two.
  OVERLAYS = "button[aria-label='#{WELCOME_CLOSE}'], #{COOKIE_DISMISS}"
  CHALLENGE_CLOSE = 'closeButton'
  BODY = 'body'
  CART = '[aria-label="Show the shopping cart"]'
  ACCOUNT_MENU = 'Show/hide account menu'
  # click_button takes a button locator and not CSS, so the id and its CSS form
  # are both needed for the same element.
  LOGOUT = 'navbarLogoutButton'
  LOGOUT_SELECTOR = '#navbarLogoutButton'

  # The app draws the basket, the checkout steps and the address list as the same
  # Material grid, so one row selector covers all of them.
  ROW = 'mat-row'
  PLAIN_ROW = 'tr.mat-row'
  TABLE_ROW = 'tr'
  OPTION = 'mat-option'
  SUBMIT_BUTTON = 'submitButton'
  ERROR = '.error'

  # Search and product cards
  SEARCH_TOGGLE = '#searchQuery'
  SEARCH_INPUT = '#searchQuery input'
  PRODUCT_NAME = 'mat-card div.name'
  PRODUCT_NAME_TEXT = 'div.name'
  PRODUCT_CARD = 'mat-card:has(div.name)'
  ADD_TO_BASKET = 'Add to Basket'
  PAGINATOR_RANGE = '.mat-mdc-paginator-range-label'
  PAGINATOR_TOUCH_TARGET = '.mat-mdc-paginator-touch-target'
  NEXT_PAGE = 'Next page'
  PREVIOUS_PAGE = 'Previous page'

  # Product dialog
  DIALOG = '.mat-mdc-dialog-container'
  DIALOG_CLOSE = 'Close Dialog'

  # Basket
  BASKET_PRODUCT_CELL = 'mat-cell.mat-column-product'
  BASKET_QUANTITY = 'mat-cell.mat-column-quantity span.cell-initial-font'
  BASKET_QUANTITY_CELL = 'mat-cell.mat-column-quantity'
  BASKET_TOTAL = '#price'
  CHECKOUT = 'checkoutButton'
  ICON_BUTTON = "button:has(svg[data-icon='%<icon>s']), button:has(i.fa-%<icon>s)"
  ICON_INCREASE = 'plus-square'
  ICON_DECREASE = 'minus-square'
  ICON_REMOVE = 'trash-alt'

  # Checkout steps
  RADIO = 'input[type="radio"]'
  CELL = 'mat-cell.mat-column-%<column>s'
  PROCEED_TO_PAYMENT = 'Proceed to payment selection'
  PROCEED_TO_DELIVERY = 'Proceed to delivery method selection'
  PROCEED_TO_REVIEW = 'Proceed to review'
  ADD_ADDRESS = 'Add a new address'
  DELIVERY_PRICE_CELL = 'mat-cell.mat-column-Price'
  CARD_NUMBER_CELL = 'mat-cell.mat-column-Number'
  COMPLETE_PURCHASE = 'Complete your purchase'
  SUMMARY_PRICE = 'td.price'
  DELIVERY_TEXT = '#deliveryText, mat-card'

  # Address list and form
  ADDRESS_NAME_CELL = 'mat-cell.mat-column-Name'
  ADDRESS_COUNTRY = 'Country'
  ADDRESS_NAME = 'Name'
  ADDRESS_MOBILE = 'Mobile Number'
  ADDRESS_ZIP = 'ZIP Code'
  ADDRESS_STREET = 'Address'
  ADDRESS_CITY = 'City'
  ADDRESS_STATE = 'State'

  # Account screens
  ORDER_HEADING = 'mat-card .heading'
  FORGOT_EMAIL = 'email'
  SECURITY_ANSWER = 'securityAnswer'
  NEW_PASSWORD = 'newPassword'
  NEW_PASSWORD_REPEAT = 'newPasswordRepeat'
  RESET = 'resetButton'

  # Register
  REGISTER_EMAIL = 'emailControl'
  REGISTER_PASSWORD = 'passwordControl'
  REGISTER_REPEAT = 'repeatPasswordControl'
  REGISTER_ANSWER = 'securityAnswerControl'
  REGISTER_BUTTON = 'registerButton'
  SECURITY_QUESTION_SELECT = 'mat-select[aria-label="Selection list for the security question"]'

  # Change password
  CURRENT_PASSWORD = 'currentPassword'
  CHANGE_PASSWORD_BUTTON = 'changeButton'
  CHANGE_PASSWORD_REPEAT_FIELD = '#newPasswordRepeat'

  # Login
  LOGIN_EMAIL = 'Email'
  LOGIN_PASSWORD = 'Password'
  LOGIN_BUTTON = 'loginButton'
  REMEMBER_ME = 'Checkbox to stay logged in or not logged in'

  # Customer feedback and complaints
  COMMENT = 'comment'
  COMMENT_FIELD = '#comment'
  CAPTCHA_INPUT = 'captchaControl'
  CAPTCHA_TEXT = '#captcha'
  RATING_SLIDER = '#rating input[type="range"]'
  AUTHOR_FIELD = '[aria-label="Field with the name of the author"]'
  COMPLAINT_MESSAGE = 'complaintMessage'
  COMPLAINT_MESSAGE_FIELD = '#complaintMessage'
  COMPLAINT_EMAIL_FIELD = '[aria-label^="Text field for the mail address"]'
end
