# Skin switcher hardening — design

## Intent

Close the review findings on the built-in palette switcher before release.
No new user-facing feature; fix state sync, ARIA, and test coverage.

## Approved scope

- `aria-checked` only on roles that allow it.
- Resync picker items at load, on `BasecoatState.mounted`, and after `updated`.
- Attach `window.basecoat.skin` at module load when `window.basecoat` exists.
- Ignore `[data-basecoat-skin]` items with `aria-disabled="true"`.
- Test that each palette's dark block defines the same tokens as its light block.
- Document that a stored choice, including `default`, wins over a server-rendered
  `data-skin`.

## Dropped finding

The reviewer asked for a warning when a hand-edited Basecoat import prevents the
`skins.css` import. `check_tailwind/2` rejects files without the Tailwind import,
and `build/10` always inserts the Basecoat import after it. The skin import is
therefore always inserted. A warning would be unreachable, so it is not added.

## Non-goals

- Eliminating the one-frame default-palette flash.
- Cross-tab sync via the `storage` event.
- Validating skin names; apps may define their own in `theme.css`.

## Behavior

- `syncSkinItems` skips elements without a role in `menuitemradio`, `radio`,
  `checkbox`, or `switch`.
- `applyStoredSkin`, `syncSkinItems`, and the API attachment run at module load.
  Hook mount and update call `syncSkinItems` again for late-joining and patched
  menus. A hook-time fallback attaches the API if `window.basecoat` appeared
  later, so manual import order still works.
- A disabled menu item does not change the palette.
- Stored value wins over markup. Clearing storage leaves the rendered
  `data-skin` in place.

## Risks

- `updated` runs on every patch; `querySelectorAll` over the document is small
  but not free. The list is tiny; scope it later only if profiling says so.
- The API attachment assumes `all.min.js` is imported first, which the installer
  guarantees. The hook-time attachment is removed, so manual setups must keep
  that order.