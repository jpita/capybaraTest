# frozen_string_literal: true

class ContactPage < BasePage
  path '/#/contact'

  def leave_feedback(comment:, rating: nil)
    fill_in(Locators::COMMENT, with: comment)
    set_rating(rating) if rating
    solve_captcha
    self
  end

  def submit
    click_button(Locators::SUBMIT_BUTTON)
    self
  end

  # The expression is generated per visit, so the answer is computed from the
  # page rather than hardcoded.
  def solve_captcha
    fill_in(Locators::CAPTCHA_INPUT, with: captcha_answer)
    self
  end

  def set_rating(stars)
    slider = find(Locators::RATING_SLIDER, visible: :all, wait: 10)
    slider.set(stars)
    self
  end

  def submit_enabled? = enabled?(Locators::SUBMIT_BUTTON)

  # Logged-in users get their own address filled in and locked.
  def author_locked? = find(Locators::AUTHOR_FIELD, wait: 10).disabled?

  def comment_limit = find(Locators::COMMENT_FIELD, wait: 10)[:maxlength].to_i

  private

  # The app generates <int><op><int><op><int> with each operator drawn from
  # '*', '+' and '-', so precedence has to be applied here: multiplication before
  # addition and subtraction. Ruby's eval is deliberately not used on page text.
  def captcha_answer
    tokens = find(Locators::CAPTCHA_TEXT, wait: 10).text.scan(/\d+|[+*-]/)
    terms = [tokens.shift.to_i]
    operators = []
    tokens.each_slice(2) do |operator, number|
      operators << operator
      terms << number.to_i
    end

    folded = [terms.first]
    remaining = []
    operators.each_with_index do |operator, index|
      if operator == '*'
        folded[-1] *= terms[index + 1]
      else
        remaining << operator
        folded << terms[index + 1]
      end
    end

    remaining.each_with_index.reduce(folded.first) do |total, (operator, index)|
      term = folded[index + 1]
      operator == '-' ? total - term : total + term
    end
  end
end
