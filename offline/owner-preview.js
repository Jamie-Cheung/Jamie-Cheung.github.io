(function () {
  "use strict";

  var STORAGE_KEY = "zhang-homepage-preview-slug";
  var form = document.getElementById("owner-unlock");
  var toggle = document.getElementById("owner-unlock-toggle");
  var input = document.getElementById("owner-unlock-key");
  var error = document.getElementById("owner-unlock-error");

  function previewUrl(slug) {
    return "/p/" + slug + "/";
  }

  function previewIndex(slug) {
    return "/p/" + slug + "/index.html";
  }

  function showError(message) {
    if (!error) return;
    error.hidden = false;
    error.textContent = message;
  }

  function hideError() {
    if (!error) return;
    error.hidden = true;
  }

  function rememberSlug(slug) {
    try {
      localStorage.setItem(STORAGE_KEY, slug);
    } catch (err) {
      /* Ignore private-mode storage failures. */
    }
  }

  function readRememberedSlug() {
    try {
      return localStorage.getItem(STORAGE_KEY) || "";
    } catch (err) {
      return "";
    }
  }

  async function sha256Hex(value) {
    var data = new TextEncoder().encode(value);
    var digest = await crypto.subtle.digest("SHA-256", data);
    return Array.from(new Uint8Array(digest))
      .map(function (byte) {
        return byte.toString(16).padStart(2, "0");
      })
      .join("");
  }

  async function slugForKey(key) {
    return (await sha256Hex(key.trim())).slice(0, 16);
  }

  async function previewExists(slug) {
    try {
      var response = await fetch(previewIndex(slug), {
        method: "GET",
        cache: "no-store",
        credentials: "same-origin",
      });
      return response.ok;
    } catch (err) {
      return false;
    }
  }

  async function openPreview(slug, options) {
    var persist = !options || options.persist !== false;
    if (!(await previewExists(slug))) {
      return false;
    }
    if (persist) {
      rememberSlug(slug);
    }
    location.replace(previewUrl(slug));
    return true;
  }

  function keyFromLocation() {
    var params = new URLSearchParams(location.search);
    var fromQuery = params.get("preview");
    if (fromQuery) return fromQuery;

    var hash = location.hash.replace(/^#/, "");
    if (!hash) return "";
    if (hash.indexOf("preview=") === 0) {
      return decodeURIComponent(hash.slice("preview=".length));
    }
    var hashParams = new URLSearchParams(hash);
    return hashParams.get("preview") || "";
  }

  function revealForm() {
    if (!form) return;
    form.hidden = false;
    if (toggle) toggle.setAttribute("aria-expanded", "true");
    if (input) input.focus();
  }

  if (toggle && form) {
    toggle.addEventListener("click", function () {
      if (form.hidden) {
        revealForm();
      } else {
        form.hidden = true;
        toggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  if (form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault();
      hideError();
      var key = input ? input.value : "";
      if (!key.trim()) {
        showError("请输入预览口令。");
        return;
      }
      slugForKey(key)
        .then(function (slug) {
          return openPreview(slug);
        })
        .then(function (ok) {
          if (!ok) {
            showError("口令不正确。");
          }
        })
        .catch(function () {
          showError("预览无法打开，请稍后再试。");
        });
    });
  }

  async function boot() {
    var key = keyFromLocation();
    if (key) {
      revealForm();
      if (input) input.value = key;
      var slug = await slugForKey(key);
      if (await openPreview(slug)) {
        return;
      }
      showError("口令不正确。");
    }

    var remembered = readRememberedSlug();
    if (remembered) {
      if (!(await openPreview(remembered))) {
        try {
          localStorage.removeItem(STORAGE_KEY);
        } catch (err) {
          /* Ignore */
        }
      }
    }
  }

  boot();
})();
