#!/usr/bin/env node
// Headless end-to-end check: restore the snapshot, run the full
// student workflow (plain dune + bisect_ppx coverage) over serial,
// assert the Coverage line. Run after every image rebuild.

import path from "node:path";
import url from "node:url";

const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
const SCRATCH = process.env.VM_SCRATCH ||
    path.join(__dirname, "..", "..", "_vm-prototype");
const { V86 } = await import(
    url.pathToFileURL(path.join(SCRATCH, "v86/build/libv86.mjs")));

const emulator = new V86({
    bios: { url: path.join(SCRATCH, "v86/bios/seabios.bin") },
    vga_bios: { url: path.join(SCRATCH, "v86/bios/vgabios.bin") },
    wasm_path: path.join(SCRATCH, "v86/build/v86.wasm"),
    autostart: true,
    memory_size: 512 * 1024 * 1024,
    vga_memory_size: 8 * 1024 * 1024,
    network_relay_url: "<UNUSED>",
    initial_state: { url: path.join(SCRATCH, "images/ocaml-state.bin") },
    filesystem: {
        // node libv86 reads chunks via fs; an http baseurl would
        // silently hang the 9p filesystem here.
        baseurl: path.join(SCRATCH, "images/ocaml-rootfs-flat") + "/",
        basefs: path.join(SCRATCH, "images/ocaml-fs.json"),
    },
});

const CMD = "cd /root/hello && dune build && dune exec ./hello.exe && " +
    "cd /root/roman && dune build && dune runtest && " +
    "time dune build --instrument-with bisect_ppx && " +
    "dune runtest --instrument-with bisect_ppx && " +
    "bisect-ppx-report summary && bisect-ppx-report html && ls _coverage\n";

let serial = "";
let sent = false;
const t0 = Date.now();
const mark = m => console.log(`\n[${((Date.now() - t0) / 1000).toFixed(1)}s] ${m}`);

emulator.add_listener("emulator-started", function () {
    // A restored snapshot emits no serial output on its own: the
    // prompt predates the snapshot. Poke the shell for a fresh one.
    setTimeout(() => emulator.serial0_send("\n"), 1000);
});

emulator.add_listener("serial0-output-byte", function (byte) {
    const c = String.fromCharCode(byte);
    serial += c;
    process.stdout.write(c);

    if (!sent && serial.endsWith(":~# ")) {
        sent = true;
        mark("prompt; sending workflow");
        emulator.serial0_send(CMD);
    }
    if (sent && /Coverage: \d+\/\d+/.test(serial) && serial.includes("index.html")) {
        mark("workflow complete: " + serial.match(/Coverage: [^\r\n]*/)[0]);
        emulator.destroy();
        process.exit(0);
    }
});

setTimeout(() => { mark("TIMEOUT"); process.exit(1); }, 15 * 60 * 1000);
