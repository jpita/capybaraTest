# frozen_string_literal: true

# The app keeps basket, session and challenge state in the browser, so an example
# that inherits the previous one's storage is not isolated. Cookies are dropped
# through the driver, the rest through the page.
module BrowserState
  def self.clear
    session = Capybara.current_session
    driver = session.driver

    if driver.respond_to?(:browser) && driver.browser.respond_to?(:manage)
      begin
        driver.browser.manage.delete_all_cookies
      rescue StandardError
        nil
      end
    end

    begin
      session.execute_script(<<~JS)
        try { localStorage.clear(); } catch (e) {}
        try { sessionStorage.clear(); } catch (e) {}
        try {
          if (indexedDB && indexedDB.databases) {
            indexedDB.databases().then((dbs) => {
              dbs.forEach((db) => {
                if (db.name) indexedDB.deleteDatabase(db.name);
              });
            });
          }
        } catch (e) {}
      JS
    rescue StandardError
      nil
    end
  end
end
