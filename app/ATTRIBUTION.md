# Attribution

## Upstream

- Project: OWASP Juice Shop
- Version: 20.2.0, read from its own `package.json`
- Commit: `1618a611b173b4bf114028e6e02549950606e29d`, dated 2026-08-10
- Licence: MIT, see [LICENSE](LICENSE)
- Copyright: 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors

This directory is a copy of that commit. The Capybara suite at the repository root drives this copy.

## What was removed

- `test/`, `cypress.config.ts`, and all 150 `*.spec.ts` files.
- Frontend test files: `src/vitest.d.ts`, `vitest-base.config.mts`, `src/tsconfig.spec.json`, `src/test-setup.ts`, `src/mocks/ng-gallery.ts`.
- The `test` target in `frontend/angular.json`, and the reference to `src/tsconfig.spec.json` in `frontend/tsconfig.json`.
- Frontend scripts: `test`, `test:coverage`, `test:watch`, `test:verbose`.
- Frontend `devDependencies`: `@vitest/coverage-v8`, `jsdom`, `vitest`.
- Root `devDependencies`: `@istanbuljs/nyc-config-typescript`, `@types/supertest`, `cypress`, `nyc`, `supertest`.
- Root `nyc` config block and the `cypress@15.17.0` entry in `allowScripts`.
- Root scripts: `cypress:open`, `cypress:run`, `test`, `test:coverage`, `test:api`, `test:api:coverage`, `test:e2e`, `test:frontend`, `test:frontend:coverage`, `test:server`, `test:server:coverage`.

`lint` and `lint:fix` no longer scan `test/**/*.ts`.

No runtime dependency was removed. Every removed package served the deleted suites only. `src/vitest.d.ts` had to go: `src/tsconfig.app.json` includes `**/*.d.ts`, so the production build failed with `TS2688: Cannot find type definition file for 'vitest/globals'` once vitest was gone.

## Generated files

`i18n/*.json` and `ftp/legal.md` are not tracked, by upstream's own rules. `lib/startup/restoreOverwrittenFilesWithOriginals.ts` recreates them at startup from `data/static/i18n/*.json` and `data/static/legal.md`, which are tracked. The startup step needs the `i18n` directory to exist, which is why upstream tracks `i18n/.gitkeep`. Verified: with `i18n` holding only `.gitkeep`, a start regenerates all 43 files byte-identical to their sources.

## Local code changes

`routes/basket.ts` answers `{ status: 'success', data: null }` when an account has no basket row, and three client sites read `.Products` on that null. Each site now falls back to an empty array:

- `frontend/src/app/Services/basket.service.ts` line 67
- `frontend/src/app/product/product.component.ts` line 74
- `frontend/src/app/purchase-basket/purchase-basket.component.ts` line 80

The `reduce` calls also tolerate a missing `BasketItem` or `price`. The Capybara suite covers each fix.

## Ignore rules

`app/.gitignore` is upstream plus one line. Upstream tracks 16 files in `frontend/src/assets/private/`, and its own `frontend/src/**/*.js` rule would drop the nine `.js` files there. The added line is:

    !frontend/src/assets/private/*.js
