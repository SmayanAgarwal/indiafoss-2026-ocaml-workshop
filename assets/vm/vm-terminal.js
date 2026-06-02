/* vm-terminal: click-to-boot Linux VM with the OCaml toolchain,
 * running entirely in the browser (v86 + xterm.js on the serial
 * console). Enhances the first <div class="vm-terminal"> on the
 * page; nothing is downloaded until the student clicks Start.
 *
 * Attributes on the div:
 *   data-dir    start directory inside the VM (e.g. /root/morse)
 *   data-base   base URL of the VM data (chunk store + snapshot)
 * Dev/test hook: a ?vmbase=<url> query parameter overrides
 * data-base (used by the playwright check to serve data locally).
 *
 * The memory geometry below MUST match the snapshot builder
 * (tools/vm-image/make-state.mjs): restoring a state into a VM
 * with different memory_size / vga_memory_size fails with
 * "RangeError: offset is out of bounds" inside set_state.
 */
(function () {
  "use strict";

  var DEFAULT_BASE = "https://fplaunchpad.org/ocaml-browser-vm/v2";

  /* Engine files (libv86.js, v86.wasm, bios, xterm.*) live next to
   * this script. */
  var script = document.currentScript;
  var ASSET_DIR = script ? script.src.replace(/\/[^/]*$/, "") : "assets/vm";

  var CSS = [
    ".vm-terminal{border:1px solid #444;border-radius:8px;overflow:hidden;",
    "  margin:1.5rem 0;background:#1e1e1e;color:#ddd;font-family:monospace}",
    ".vm-terminal .vm-placeholder{padding:1.2rem;display:flex;flex-direction:column;",
    "  gap:.6rem;align-items:flex-start}",
    ".vm-terminal .vm-blurb{font-size:.85rem;color:#aaa;margin:0}",
    ".vm-terminal button.vm-start{font:inherit;font-size:1rem;padding:.45rem 1.1rem;",
    "  border-radius:6px;border:1px solid #6a6;background:#2d4d2d;color:#dfd;cursor:pointer}",
    ".vm-terminal button.vm-start:hover{background:#3a663a}",
    ".vm-terminal button.vm-start[disabled]{opacity:.5;cursor:default}",
    ".vm-terminal .vm-term{padding:.5rem .5rem 0 .5rem;display:none}",
    ".vm-terminal .vm-status{font-size:.78rem;color:#8c8;padding:.35rem .8rem;",
    "  border-top:1px solid #333;min-height:1.2em}",
  ].join("\n");

  function injectOnce(id, make) {
    if (!document.getElementById(id)) {
      var el = make();
      el.id = id;
      document.head.appendChild(el);
    }
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = src;
      s.onload = resolve;
      s.onerror = function () { reject(new Error("failed to load " + src)); };
      document.head.appendChild(s);
    });
  }

  function fmtMB(bytes) { return (bytes / 1048576).toFixed(1) + " MB"; }

  function downloadedBytes(base) {
    var total = 0;
    var entries = performance.getEntriesByType("resource");
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      if (e.name.indexOf(base) === 0 || e.name.indexOf(ASSET_DIR) === 0) {
        /* transferSize only: cache hits report 0 and must not count */
        total += e.transferSize || 0;
      }
    }
    return total;
  }

  function boot(root) {
    var params = new URLSearchParams(location.search);
    var base = params.get("vmbase") || root.dataset.base || DEFAULT_BASE;
    base = base.replace(/\/$/, "");
    var startDir = root.dataset.dir || "";

    var status = root.querySelector(".vm-status");
    var termDiv = root.querySelector(".vm-term");
    var setStatus = function (msg) { status.textContent = msg; };

    performance.setResourceTimingBufferSize(50000);
    setStatus("loading terminal + emulator ...");

    injectOnce("vm-xterm-css", function () {
      var l = document.createElement("link");
      l.rel = "stylesheet";
      l.href = ASSET_DIR + "/xterm.css";
      return l;
    });

    return loadScript(ASSET_DIR + "/xterm.js")
      .then(function () { return loadScript(ASSET_DIR + "/libv86.js"); })
      .then(function () {
        var term = new window.Terminal({
          cols: 80, rows: 24,
          cursorBlink: true,
          fontSize: 14,
          theme: { background: "#1e1e1e" },
        });
        termDiv.style.display = "block";
        term.open(termDiv);

        setStatus("starting VM (downloading boot snapshot) ...");
        var emulator = new window.V86({
          wasm_path: ASSET_DIR + "/v86.wasm",
          bios: { url: ASSET_DIR + "/seabios.bin" },
          vga_bios: { url: ASSET_DIR + "/vgabios.bin" },
          /* must match make-state.mjs (see header comment) */
          memory_size: 512 * 1024 * 1024,
          vga_memory_size: 8 * 1024 * 1024,
          initial_state: { url: base + "/ocaml-state.bin.zst" },
          filesystem: {
            baseurl: base + "/ocaml-rootfs-flat/",
            basefs: base + "/ocaml-fs.json",
          },
          autostart: true,
          /* All input goes through xterm -> serial0. Without these,
           * v86's emulated PS/2 devices grab page-global key and
           * mouse events and the page stops scrolling. */
          disable_keyboard: true,
          disable_mouse: true,
          disable_speaker: true,
        });
        root.vmEmulator = emulator; /* for tests and consoles */

        /* serial0 <-> xterm, with batched writes */
        var pending = [];
        var flushScheduled = false;
        emulator.add_listener("serial0-output-byte", function (byte) {
          pending.push(byte);
          if (!flushScheduled) {
            flushScheduled = true;
            setTimeout(function () {
              flushScheduled = false;
              term.write(new Uint8Array(pending));
              pending = [];
            }, 0);
          }
        });
        term.onData(function (data) { emulator.serial0_send(data); });

        emulator.add_listener("emulator-started", function () {
          setTimeout(function () {
            /* a restored snapshot prints nothing until poked */
            if (startDir) {
              emulator.serial0_send("cd " + startDir + " && clear\n");
            } else {
              emulator.serial0_send("\n");
            }
            term.focus();
          }, 600);
        });

        var iv = setInterval(function () {
          setStatus("running; downloaded " + fmtMB(downloadedBytes(base)) +
                    " (fetched on demand as you use files)");
        }, 1000);
        window.addEventListener("pagehide", function () { clearInterval(iv); });
      })
      .catch(function (err) {
        setStatus("failed to start: " + err.message);
        throw err;
      });
  }

  function enhance(root) {
    injectOnce("vm-terminal-css", function () {
      var st = document.createElement("style");
      st.textContent = CSS;
      return st;
    });

    var dir = root.dataset.dir || "";
    root.innerHTML =
      '<div class="vm-placeholder">' +
      '<button class="vm-start" type="button">Start the VM</button>' +
      '<p class="vm-blurb">Boots a tiny Linux machine in this page with ' +
      "OCaml 5.4, dune, and bisect_ppx preinstalled" +
      (dir ? ", starting in <code>" + dir + "</code>" : "") +
      ". Initial download is about 12 MB; project files and tools are " +
      "fetched on demand as you use them. Nothing runs on a server: it " +
      "is all in your browser tab.</p>" +
      "</div>" +
      '<div class="vm-term"></div>' +
      '<div class="vm-status"></div>';

    var btn = root.querySelector("button.vm-start");
    btn.addEventListener("click", function () {
      btn.disabled = true;
      boot(root).then(function () {
        root.querySelector(".vm-placeholder").style.display = "none";
      }, function () {
        btn.disabled = false;
      });
    });
  }

  function init() {
    var roots = document.querySelectorAll("div.vm-terminal");
    if (roots.length === 0) return;
    if (roots.length > 1) {
      console.warn("vm-terminal: multiple instances found; enhancing only " +
                   "the first (each VM holds the 512 MB guest RAM buffer)");
    }
    enhance(roots[0]);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
