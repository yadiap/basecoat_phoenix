# Manual verification

Browser checks for behavior that unit tests cannot prove. Run each check in a
Phoenix 1.8 app that has `mix basecoat.install --replace-ui` applied; the
installer already wires `priv/basecoat/basecoat_live.js` through
`BasecoatHooks` in `assets/js/app.js`.

## Setup

1. Add `{:basecoat_phoenix, path: "..."}`.
2. Run `mix basecoat.install --replace-ui`.
3. In `html_helpers`, add `use BasecoatPhoenix.Components`.
4. Start `mix phx.server`.

## Button

- Render `<.bc_button>Save</.bc_button>`; confirm Basecoat's primary styling.
- `variant="outline"` and `size="sm"` change the look; no `data-variant` or
  `data-size` appears for the defaults.
- `href="/x"` renders an `<a>` and still navigates.
- A button with `phx-click` fires and receives the click.

## Card

- Render a card with header, title, description, action, content, and footer.
- Confirm spacing and borders match the upstream card example.
- An unrelated LiveView assign update does not change the card layout.

## Dialog

- Click `bc_dialog_trigger`; the dialog opens modally (page scroll blocked,
  backdrop visible).
- Click the backdrop; the dialog closes.
- Click the close button; the dialog closes.
- Press Escape; the dialog closes.
- Open the dialog, then trigger an unrelated LiveView update (`phx-click` that
  changes another assign). The dialog stays open and the page content is still
  inert.
- Render `open` initially; it opens modally on mount, not as a bare attribute.
- Server-side close with `JS.dispatch("basecoat:close-dialog", to: "#id")`
  works.

## Select

- Click the trigger; the listbox opens and is positioned under it.
- Click an option; the trigger label updates, the option is marked
  `aria-selected`, and the hidden input carries the value.
- Submit the enclosing form; `phx-change`/`phx-submit` receive the value.
- With `multiple`, select two options; the hidden input is a JSON array and
  `BasecoatPhoenix.Forms.decode_multi/1` decodes it.
- With `format="object"`, the hidden input holds JSON objects with
  `value` and `label`.
- Open the listbox, then trigger an unrelated LiveView update. The listbox stays
  open and the selection is preserved.
- With dynamic server options, update the options assign; the refreshed listbox
  shows the new options.

## Button group

- Wrap two outline buttons in `<.bc_button_group label="Actions">`.
- Confirm the buttons share one visual group with joined borders.
- `aria-label` is present when `label` is set and absent otherwise.

## Badge

- Render each variant: default, secondary, destructive, outline, ghost.
- Confirm the default omits `data-variant` and each other variant matches its
  Basecoat style.
- An inline icon with `data-icon="inline-start"` gets icon-aware spacing.

## Avatar

- Render an avatar with `<.bc_avatar_image>` and `<.bc_avatar_fallback>`.
- With a valid image URL, the image covers the fallback; with a broken URL, the
  fallback initials show.
- `size="sm"` and `size="lg"` resize the avatar.
- `bc_avatar_badge` sits in the block-end inline-end corner.
- `bc_avatar_group` overlaps its children.

## Kbd

- `bc_kbd` renders the key style; a class such as `translate-x-0.5` applies.

## Separator

- `bc_separator` renders a horizontal rule.
- `orientation="vertical"` fills the height of its flex row.
- `decorative` renders `role="none"`, so assistive tech skips it.

## Skeleton

- `bc_skeleton class="h-4 w-full"` renders a shimmering placeholder.
- The class carries all sizing; the component adds no size of its own.

## Spinner

- `bc_spinner` spins.
- `class="size-3"` (or another `size-*`) resizes it.
- Inside a button, icon-aware spacing applies.

## Progress

- `value={13}` renders a 13% fill.
- Values above `max` clamp to 100%; negative values clamp to 0%.
- A third of the way renders `33.3%`.
- `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, and the label wiring are
  present for assistive tech.

## Input, textarea, native select, label

- `bc_input` and `bc_textarea` take Basecoat's input styling; `class` merges
  with the base class.
- Submitting the enclosing form sends the `name`/`value` pair.
- With `field={@form[:name]}`, the id, name, and value come from the field, and
  a field error adds `aria-invalid="true"` plus `aria-describedby="<id>-error"`.
- `bc_native_select` renders native `<option>` children; the current value is
  preselected and a disabled option cannot be chosen.
- `bc_label` matches upstream and `for=` focuses its control.

## Field, fieldset

- `bc_fieldset` renders a real `<fieldset>` with a `<legend>`;
  `as="div"` renders `<div role="group">` instead.
- `bc_field` lays out a label, control, description, and error with the
  upstream spacing.
- `bc_field_description` and `bc_field_error` produce `id="<id>-description"`
  and `id="<id>-error"`; the error is announced as `role="alert"`.

## Checkbox, radio group, switch, toggle, toggle group

- `bc_checkbox` toggles on label click; `description` moves the label into a
  `<section>` with helper text and wires `aria-describedby`.
- `bc_radio_group_item` shows only one selected radio per `name`.
- `bc_switch` renders a native checkbox with `role="switch"`; the knob animates.
- `bc_toggle` renders a button-styled label whose native input still submits.
- `bc_toggle_group` submits every checked value; `single: true` renders radios
  so only one value is submitted.
- Keyboard: Tab reaches each control, Space toggles it, arrow keys move within
  a radio group.

## Input group

- `bc_input_group` renders a borderless input inside the group shell.
- `data-align="start|end"` addons sit on the correct side and flip under RTL.
- `bc_input_group_button as="group"` renders `<div role="group">` for several
  related actions.

## Input OTP

- Typing fills the slot spans one character at a time and the caret follows.
- Backspace and paste behave; a paste longer than `length` truncates.
- With `filter`, a paste containing a disallowed character is rejected
  (requires `pattern`).
- The real input still submits its `value` with the form.
- An unrelated LiveView patch leaves the typed code and slots intact
  (`phx-update="ignore"`).

## Slider

- Dragging the thumb updates the filled track.
- A server-side value change (for example a `phx-click` that raises the value)
  repaints the fill without a page reload.
- `min`/`max`/`step` behave natively; a zero-width range renders an empty fill.

## Combobox

- Typing filters the listbox; the empty state uses `data-empty`.
- Clicking an option sets the hidden input and the visible label.
- With `multiple`, the hidden input is a JSON array; with
  `format="object"`, JSON objects with `value` and `label`.
- With `clear`, the clear button empties the selection and the chevron button
  opens the listbox.
- Grouped options show a heading per group.
- An unrelated LiveView patch keeps the open listbox and the filter text.

## Item

- `bc_item` renders a display row; `href` makes the whole row a link.
- Media, content, actions, header, and footer land in the upstream slots.
- `variant` (`outline`, `muted`) and `size` (`sm`, `xs`) change the look.
- `bc_item_group` stacks related items.

## Empty

- `bc_empty` renders the centered empty state with media, title, and
  description.
- An icon-only figure is styled automatically.
- `bc_empty_content` or `bc_empty_footer` holds the actions.

## Collapsible

- Clicking the summary expands and collapses the content.
- Keyboard: Tab reaches the summary, Enter and Space toggle it.
- The open state survives an unrelated LiveView patch, because the browser
  owns `<details>`.

## Accordion

- The first item starts open when `open` is set.
- Opening one item closes the others unless `multiple` is set.
- The chevron rotates on open.
- `disabled` renders `aria-disabled="true"`; Basecoat blocks the toggle.
- The open item stays open across an unrelated LiveView patch.

## Sidebar

- `bc_sidebar_trigger` opens and closes the sidebar it names.
- `side="left"` and `side="right"` place it physically; `data-breakpoint`
  sets the mobile breakpoint.
- `initial_open: "false"` starts it closed on desktop;
  `initial_mobile_open: "true"` starts it open on mobile.
- Clicking a link inside the mobile sidebar closes it unless the control
  carries `data-keep-mobile-sidebar-open`.
- `bc_sidebar_menu_sub` opens and closes natively.
- `active` marks the current item; `data-active="true"` styles it.
- The open state survives an unrelated LiveView patch.

## Alert

- The icon, title, description, and actions render as direct children in the
  upstream order.
- `variant="destructive"` recolors the alert.
- Actions land in a `<footer>` pinned to the inline end.

## Bubble

- The bubble sizes to its content, up to 80% of its container.
- `variant` accepts `secondary`, `muted`, `tinted`, `outline`, `ghost`, and
  `destructive`.
- `align="end"` puts an outgoing message on the inline end edge.
- Each `:reactions` entry renders a direct `<div role="img">` with the label
  you give it.
- `bc_bubble_group` stacks tightly spaced bubbles.
- A link or button as the content makes the whole bubble interactive.

## Message

- `bc_message_group` renders the `<ol role="list">`; each `bc_message` is one
  row.
- The avatar, sender, and bubble are yours to compose inside the message.
- `align="end"` reverses the row for outgoing messages.
- `as="div"` renders a standalone message outside a list.
- `bc_message_group` with `class="message-group"` hides the repeated avatar.

## Marker

- An optional `:icon` renders a decorative SVG before the text.
- `variant="separator"` draws rules on both sides; `border` draws a row border.
- `shimmer` animates the text; it stays static under reduced motion.
- `role="status"` announces updates when you set it.

## Attachment

- The root is a `<div>`; `as="li"` renders a list item.
- Media, content, and actions render in upstream order.
- `orientation="vertical"` stacks the thumbnail above the label.
- `state="uploading"` or `"error"` colors the card.
- A direct `<a>` or `<button>` child makes the whole card clickable; keep
  action buttons in the final actions wrapper.
- `attachment-group` on the surrounding list gives the horizontal scroll strip.

## Trace

- `bc_trace` renders the `<ol role="list">`; each `bc_trace_item` is a step.
- `details` turns the line into a `<summary>` that expands the detail; `open`
  starts it expanded.
- Without `details`, the line renders statically; `as="p"` or `href` picks a
  paragraph or a link.
- `meta` renders the trailing `<small>` for a duration or count.
- The chevron comes from CSS, so no extra markup is needed.

## Table

- `bc_table_container` scrolls horizontally when the table is wider than its
  parent.
- Caption, header, body, and footer render the native elements.
- `scope="col"` on `bc_table_head` and `colspan`/`rowspan` on cells pass
  through.

## Code Block

- The header shows the title on the start edge and the actions on the end
  edge.
- The Copy button copies the visible code and shows its copied state.
- `data-line-numbers` on the `<pre>` numbers each line; the numbers are
  excluded from selection and from the copied text.
- `data-size="sm"` shrinks the block.
- Copy needs HTTPS or localhost; a failure is announced, not faked.

## Chart

- With Chart.js loaded, the canvas draws the chart and the legend renders
  below it.
- Changing the chart data through a LiveView update redraws the canvas.
- Without Chart.js, the console logs one clear error and the page still
  renders.
- The canvas needs no wrapper; Basecoat adds its own sizing container.

## To be added

These sections are filled in as later tasks land:

- Alert dialog
- Carousel
- Command, command dialog
- Dropdown menu
- Popover
- Tabs
- Toast (Task 13)
- Theme switcher