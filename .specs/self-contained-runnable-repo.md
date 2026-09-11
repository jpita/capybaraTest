# Self-contained, runnable E2E test repository

## 1. Goal

Make this repository self-contained and trustworthy, so a reviewer can clone it, run the
application, run the suite, and be left with a clean database.

The decision it drives: whether a reviewer can judge the work without asking for
anything from me.

## 2. Out of scope

- Changing application behaviour, beyond the three fixes already made.
- Contributing those fixes upstream.
- Adding or changing test scenarios. The 68 examples stay as they are.
- CI configuration, Docker, and publishing.
- Rewriting the vendored application's internals.

## 3. Buckets

### Bucket 1. Vendor the application into `app/`

Outcome: `app/` contains OWASP Juice Shop 20.2.0 at commit
`1618a611b173b4bf114028e6e02549950606e29d`, with the three fixes included as real source.
A clone plus `npm install` plus `npm start` serves the application on port 3000.

Files touched:
- new `app/` (about 29M of source)
- `app/ATTRIBUTION.md`
- root `.gitignore`

Excluded from the copy: `.git`, `node_modules`, `frontend/node_modules`, `build`, `logs`,
`frontend/dist`, `data/juiceshop.sqlite`.

Checkpoint: show the tree and the size. Boot the application from `app/` and confirm the
catalogue loads and adding to the basket does not crash.

### Bucket 2. One place for every selector

Outcome: every CSS selector, element id and aria-label lives in one file. A UI change is
one edit.

Files touched:
- new `spec/support/locators.rb`
- all files in `spec/pages/`

Duplication to remove, with current locations:
- the enabled check, 9 copies across 7 files, in two different implementations:
  `spec/pages/contact_page.rb:33`, `spec/pages/search_page.rb:65`,
  `spec/pages/search_page.rb:66`, `spec/pages/checkout_pages.rb:27`,
  `spec/pages/checkout_pages.rb:76`, `spec/pages/register_page.rb:36`,
  `spec/pages/complain_page.rb:18`, `spec/pages/account_pages.rb:78`,
  `spec/pages/change_password_page.rb:23`
- `mismatch_error?`, identical in `spec/pages/register_page.rb:38` and
  `spec/pages/change_password_page.rb:25`
- dead code: `toast_message` at `spec/pages/base_page.rb:73`, unused since every
  assertion moved to `has_toast?` or `has_confirmation?`

Design point: the application marks a disabled control two ways. The paginator buttons
carry only `aria-disabled="true"`, because of `disabledInteractive`. The checkout buttons
carry a real `disabled` binding. One `enabled?` helper will treat a control as enabled
only when it has neither, which covers both mechanisms in one place.

Checkpoint: the suite stays green. Show the duplicate count before and after.

### Bucket 3. Setup and teardown

Outcome: the suite resets the database before and after a run, clears browser state per
example, and fails fast with a clear message when the application is unreachable.

Files touched:
- new `bin/app` (start, stop, restart, status), with a PID file and a log file
- `spec/spec_helper.rb`
- new `Rakefile`

Mechanism: `server.ts:755` calls `await sequelize.sync({ force: true })` inside `start()`.
A restart is therefore a database reset. `bin/app restart` will also delete
`data/juiceshop.sqlite` for certainty.

Why reset is needed at all: `DELETE /api/Users/:id` is `security.denyAll()` at
`server.ts:386`, so the application offers no way to delete a test account. A full suite
run leaves about 40 accounts, plus their baskets, addresses, cards and orders.

Consequence to accept: the application must be started through `bin/app`, because the
PID file is how the suite stops it. A manual browser session resets when the suite runs.

Checkpoint: cold-start the suite. Afterwards show the account count is back to the seeded
baseline.

### Bucket 4. README

Outcome: a reviewer understands what the suite proves and can run it in three commands.

Files touched:
- `README.md`
- `LICENSE`

Order of the README, because the reader is a reviewer:
1. What the suite demonstrates, with the concrete numbers.
2. What is under test and why the application is vendored.
3. Architecture, including the page object layout and where selectors live.
4. Setup and run, in three commands.
5. How to add a page object and a scenario.
6. Attribution for the vendored application.

Checkpoint: you read it.

### Bucket 5. Verification

Outcome: 68 examples green, no duplication, no dead code.

Files touched: `spec/` only.

Checkpoint: full-suite output, plus the list of what was removed.

## 4. Decisions confirmed

- The application is vendored into `app/`, not a submodule and not a fetch script.
- The suite resets the database before and after, driven by `bin/app`, by the suite.
- The vendored application's own test suites are stripped. The two regression specs added
  during the fix work are kept, because they document the fixes.
- The README leads with what the suite demonstrates, for a reviewer.
- The npm scripts that reference the removed tests are removed with them.
  `ATTRIBUTION.md` records exactly what was taken out.
- `spec/` and `.specs/` are part of the repository content and are committed.
- The repository is public, so commits use `--author="Claude <>"` with the human as a
  `Co-authored-by` trailer using `dvpita@gmail.com`, set repo-local before the first commit.

## 5. Open questions

None.

## 6. Verification

Bucket 1:
- `ls app/` shows no `node_modules`, no `build`, no `data/juiceshop.sqlite`.
- Start from `app/` and read the running page with Playwright or CDP. Confirm 16 product
  cards and a basket that accepts an item, which is the behaviour the crash broke.
- `git grep -c Array.isArray app/frontend/src/app` returns the three fixed sites.

Bucket 2:
- `grep -rn "def submit_enabled?\|def continue_enabled?\|def next_page_enabled?"
  spec/pages/` returns nothing, or one shared definition.
- Every selector string appears exactly once in the repository.
- `bundle exec rspec` stays at 68 examples, 0 failures.

Bucket 3:
- Run the suite from a cold start with no application running. Confirm it starts or
  refuses with one clear line.
- Count users before and after. The count after equals the count before the suite.
- `bin/app status` reports correctly when the application is up and when it is down.

Bucket 4:
- A reviewer can follow the setup section on a clean machine and reach a green run.
- Every command in the README is one I ran in this session.

Bucket 5:
- `bundle exec rspec` reports 68 examples, 0 failures.
- `grep -rn toast_message spec/` returns nothing.
- A read of every file in `spec/` for duplicated logic.
