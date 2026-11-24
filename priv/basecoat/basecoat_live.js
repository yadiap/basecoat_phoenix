// LiveView glue for Basecoat. No inline handlers, CSP-safe.
//
// Basecoat's own controllers own client state; this file only preserves that
// state across LiveView patches, relays events, and syncs overlays.

const IGNORED_ATTRIBUTE = (name) => name.startsWith("phx-") || name.startsWith("data-phx-");

const DIALOG_SELECTORS = [".dialog", ".alert-dialog", ".drawer", ".sheet", ".command-dialog"];
const OVERLAY_SELECTOR = DIALOG_SELECTORS.map((s) => `dialog${s}`).join(",");
const BASE_COAT_OWNED_BACKDROP = [".drawer", ".sheet"];
const PROPERTIES = ["value", "checked", "selectedIndex", "open", "hidden"];

const SKIN_KEY = "themeSkin";
const SKIN_SELECTOR = "[data-basecoat-skin]";

const storedSkin = () => {
  try {
    return localStorage.getItem(SKIN_KEY);
  } catch {
    return null;
  }
};

const currentSkin = () => document.documentElement.dataset.skin || "default";

const syncSkinItems = () => {
  const active = currentSkin();
  document.querySelectorAll(SKIN_SELECTOR).forEach((item) => {
    const name = item.getAttribute("data-basecoat-skin") || "default";
    item.setAttribute("aria-checked", name === active ? "true" : "false");
  });
};

const setSkin = (name) => {
  const skin = !name || name === "default" ? null : name;

  if (skin) document.documentElement.dataset.skin = skin;
  else delete document.documentElement.dataset.skin;

  try {
    localStorage.setItem(SKIN_KEY, skin || "default");
  } catch {}

  syncSkinItems();
  document.dispatchEvent(
    new CustomEvent("basecoat:skinchange", { detail: { skin: skin || "default" } }),
  );
};

const applyStoredSkin = () => {
  const stored = storedSkin();
  if (stored !== null) setSkin(stored);
};

const isFormElement = (el) =>
  el instanceof HTMLInputElement ||
  el instanceof HTMLTextAreaElement ||
  el instanceof HTMLSelectElement;

const elementKey = (el) => {
  if (el.id) return `#${el.id}`;
  if (el.getAttribute("name")) return `@${el.getAttribute("name")}`;

  const tag = el.tagName.toLowerCase();
  let index = 0;
  let sibling = el.previousElementSibling;

  while (sibling) {
    if (sibling.tagName.toLowerCase() === tag) index += 1;
    sibling = sibling.previousElementSibling;
  }

  return `${tag}#${index}`;
};

const snapshot = (root) => {
  const entries = new Map();
  entries.set(elementKey(root), capture(root));

  root.querySelectorAll("*").forEach((el) => {
    entries.set(elementKey(el), capture(el));
  });

  return entries;
};

const capture = (el) => {
  const attrs = {};

  for (const attr of Array.from(el.attributes)) {
    if (IGNORED_ATTRIBUTE(attr.name)) continue;
    attrs[attr.name] = attr.value;
  }

  const props = {};

  if (isFormElement(el) || el instanceof HTMLDetailsElement) {
    for (const name of PROPERTIES) {
      const value = el[name];
      if (value !== undefined) props[name] = value;
    }
  }

  return { attrs, props };
};

const changedNames = (baseline, server) => {
  const changed = new Set();
  if (!baseline || !server) return changed;

  const baselineSrc = baseline.attrs;
  const serverSrc = server.attrs;

  for (const name of new Set([...Object.keys(baselineSrc), ...Object.keys(serverSrc)])) {
    if (baselineSrc[name] !== serverSrc[name]) changed.add(`attr:${name}`);
  }

  for (const name of PROPERTIES) {
    if (baseline.props[name] !== server.props[name]) changed.add(`prop:${name}`);
  }

  return changed;
};

// Keys with no stable id or name collide; fall back to positional suffixes.
const disambiguate = (map) => {
  const seen = new Map();
  const out = new Map();

  for (const [key, value] of map) {
    const count = seen.get(key) || 0;
    seen.set(key, count + 1);
    out.set(count === 0 ? key : `${key}~${count}`, value);
  }

  return out;
};

const openModally = (dialog, force) => {
  if (!dialog.open) {
    dialog.showModal();
  } else if (force && !dialog.matches(":modal")) {
    dialog.close();
    dialog.showModal();
  }
};

const syncOverlays = (root, client, server, changed, baseline) => {
  const roots = [];

  if (root.matches(OVERLAY_SELECTOR)) roots.push(root);
  root.querySelectorAll(OVERLAY_SELECTOR).forEach((el) => roots.push(el));

  for (const dialog of roots) {
    const key = elementKey(dialog);
    const delta = changed.get(key);

    if (delta && (delta.has("attr:open") || delta.has("prop:open"))) {
      if (dialog.open) openModally(dialog, true);
      else if (dialog.open !== false) dialog.close();
      continue;
    }

    const before = client.get(key);
    if (!before) continue;

    if (before.props.open && !dialog.open) openModally(dialog);
    else if (!before.props.open && dialog.open) dialog.close();
  }

  // A dialog rendered open by the server was never modal; upgrade it once.
  if (root.matches(OVERLAY_SELECTOR) && root.open) openModally(root, true);
  root.querySelectorAll(OVERLAY_SELECTOR).forEach((el) => {
    if (el.open) openModally(el, true);
  });
};

const bindBackdrop = (root) => {
  const roots = [];

  if (root.matches(OVERLAY_SELECTOR)) roots.push(root);
  root.querySelectorAll(OVERLAY_SELECTOR).forEach((el) => roots.push(el));

  for (const dialog of roots) {
    if (BASE_COAT_OWNED_BACKDROP.some((sel) => dialog.matches(sel))) continue;
    if (dialog.dataset.basecoatBackdrop === "true") continue;
    dialog.dataset.basecoatBackdrop = "true";

    let pressed = false;
    dialog.addEventListener("pointerdown", (event) => {
      pressed = event.target === dialog;
    });
    dialog.addEventListener("pointerup", () => {
      pressed = false;
    });
    dialog.addEventListener("click", (event) => {
      if (pressed && event.target === dialog) dialog.close();
      pressed = false;
    });
  }
};

// LiveView's join patch drops the attributes Basecoat adds at init (role,
// tabindex, init markers) because the server never rendered them. Re-init once
// after mount so the runtime restores them. Never re-init on
// phx:page-loading-stop: a second init adds a second click listener, and a
// click then toggles the component twice. The forced re-init destroys the old
// listeners first.
let runtimeSynced = false;

const syncRuntime = () => {
  if (runtimeSynced) return;
  runtimeSynced = true;
  // Deferred so every hook's baseline snapshot lacks the runtime attributes.
  // Keep this after the snapshot or updated() treats them as server changes.
  // setTimeout, not requestAnimationFrame: rAF is paused in a hidden tab.
  setTimeout(() => {
    window.basecoat?.initAll?.({ force: true });
    syncSkinItems();
    if (window.basecoat) window.basecoat.skin = { set: setSkin, current: currentSkin };
  }, 0);
};

export const BasecoatState = {
  mounted() {
    this._baseline = disambiguate(snapshot(this.el));
    syncOverlays(this.el, this._baseline, this._baseline, new Map(), this._baseline);
    bindBackdrop(this.el);
    syncRuntime();
  },

  beforeUpdate(toEl) {
    this._client = disambiguate(snapshot(this.el));
    this._server = disambiguate(snapshot(toEl));

    const changed = new Map();

    for (const [key, server] of this._server) {
      const delta = changedNames(this._baseline.get(key), server);
      if (delta.size > 0) changed.set(key, delta);
    }

    this._changed = changed;
  },

  updated() {
    const current = disambiguate(snapshot(this.el));

    for (const [key, client] of this._client) {
      const el = this._elementFor(key);
      if (!el) continue;

      const now = current.get(key) || { attrs: {}, props: {} };
      const delta = this._changed.get(key) || new Set();

      for (const name of new Set([
        ...Object.keys(client.attrs),
        ...Object.keys(now.attrs),
      ])) {
        if (delta.has(`attr:${name}`)) continue;
        const value = client.attrs[name];
        if (value === undefined) el.removeAttribute(name);
        else if (el.getAttribute(name) !== value) el.setAttribute(name, value);
      }

      for (const name of PROPERTIES) {
        if (delta.has(`prop:${name}`)) continue;
        if (!(name in client.props)) continue;
        if (el[name] !== client.props[name]) el[name] = client.props[name];
      }
    }

    syncOverlays(this.el, this._client, this._server, this._changed, this._baseline);

    if (window.basecoat?.refresh) window.basecoat.refresh(this.el);

    this._baseline = this._server;
  },

  _elementFor(key) {
    if (key.startsWith("#")) return document.getElementById(key.slice(1));

    if (key.startsWith("@")) {
      return Array.from(this.el.querySelectorAll("[name]")).find(
        (el) => el.getAttribute("name") === key.slice(1),
      );
    }

    const [tag] = key.split("#");
    if (this.el.tagName.toLowerCase() === tag && elementKey(this.el) === key) return this.el;

    return Array.from(this.el.querySelectorAll("*")).find((el) => elementKey(el) === key);
  },
};

const CHART_KEYS = [
  "data-chart-data",
  "data-chart-series",
  "data-chart-type",
  "data-chart-label-key",
  "data-chart-legend",
  "data-chart-tooltip",
  "data-chart-options",
  "data-chart-chart-data",
];

const parseJson = (el, name) => {
  const raw = el.getAttribute(name);
  if (!raw) return undefined;
  try {
    return JSON.parse(raw);
  } catch {
    console.error(`Basecoat chart ignored invalid JSON in ${name}.`);
    return undefined;
  }
};

export const BasecoatChart = {
  mounted() {
    this.render();
  },

  updated() {
    const signature = CHART_KEYS.map((key) => this.el.getAttribute(key)).join("\u0000");
    if (signature === this._signature) return;
    this.render();
  },

  render() {
    const canvas = this.el;

    if (!window.basecoat?.chart) {
      console.error("Basecoat chart unavailable: the Basecoat chart script is not loaded.");
      return;
    }

    if (!window.Chart) {
      console.error("Basecoat chart unavailable: load Chart.js before using bc_chart.");
      return;
    }

    // The controller reads type, labelKey, legend, tooltip, data, and series
    // from data-chart-* itself. options and chartData have no attribute
    // fallback, so pass them explicitly.
    const options = { options: parseJson(canvas, "data-chart-options") };
    const chartData = { chartData: parseJson(canvas, "data-chart-chart-data") };

    canvas._basecoatChart?.destroy?.();
    window.basecoat.chart(canvas, { ...options, ...chartData });
    canvas._basecoatChart = window.Chart.getChart?.(canvas) || canvas._basecoatChart;
    this._signature = CHART_KEYS.map((key) => canvas.getAttribute(key)).join("\u0000");
  },
};

const dialogById = (id) => document.getElementById(id);

const closeDialog = (target) => {
  const dialog = target?.closest?.("dialog");
  if (dialog?.open) dialog.close();
};

const openDialog = (id) => {
  const dialog = dialogById(id);
  if (dialog && !dialog.open) dialog.showModal();
};

const toast = (payload) => {
  const toaster = document.getElementById("toaster");
  if (toaster?.toast) toaster.toast(payload);
};

const handleClick = (event) => {
  const open = event.target.closest?.("[data-basecoat-dialog-open]");
  if (open) return openDialog(open.getAttribute("data-basecoat-dialog-open"));

  const close = event.target.closest?.("[data-basecoat-dialog-close]");
  if (close) return closeDialog(close);

  const drawerOpen = event.target.closest?.("[data-basecoat-drawer-open]");
  if (drawerOpen) return openDialog(drawerOpen.getAttribute("data-basecoat-drawer-open"));

  const drawerClose = event.target.closest?.("[data-basecoat-drawer-close]");
  if (drawerClose) return closeDialog(drawerClose);

  const sidebar = event.target.closest?.("[data-basecoat-sidebar-toggle]");
  if (sidebar) {
    const target = dialogById(sidebar.getAttribute("data-basecoat-sidebar-toggle"));
    return target?.toggle?.();
  }

  const theme = event.target.closest?.("[data-basecoat-theme-toggle]");
  if (theme) return window.basecoat?.theme?.toggle?.();

  const skin = event.target.closest?.(SKIN_SELECTOR);
  if (skin) return setSkin(skin.getAttribute("data-basecoat-skin"));
};

const handleCustomEvent = (event) => {
  const id = event.detail?.id;
  const detail = event.detail;

  switch (event.type) {
    case "basecoat:open-dialog":
    case "basecoat:open-drawer":
      return openDialog(id);
    case "basecoat:close-dialog":
    case "basecoat:close-drawer":
      return closeDialog(id ? dialogById(id) : event.target);
    case "basecoat:toast":
      return toast(detail);
  }
};

// Basecoat dispatches `change` on the component root; LiveView listens on the
// hidden input. Re-dispatch without letting the hidden input's own event loop.
const handleChange = (event) => {
  const target = event.target;

  if (!(target instanceof Element)) return;
  if (!target.matches(".select, .combobox")) return;

  const input = target.querySelector(':scope > input[type="hidden"]');
  if (input) input.dispatchEvent(new Event("change", { bubbles: true }));
};

export const BasecoatHooks = { BasecoatState, BasecoatChart };

if (typeof document !== "undefined") {
  applyStoredSkin();
  document.addEventListener("click", handleClick);

  for (const type of [
    "basecoat:open-dialog",
    "basecoat:close-dialog",
    "basecoat:open-drawer",
    "basecoat:close-drawer",
    "basecoat:toast",
  ]) {
    document.addEventListener(type, handleCustomEvent);
  }

  document.addEventListener("change", handleChange);
  window.addEventListener("phx:basecoat_toast", (event) => toast(event.detail));
}
