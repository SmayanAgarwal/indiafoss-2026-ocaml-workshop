#!/usr/bin/env node
// One-off: restore the snapshot and run the M10 C demos over serial,
// printing the full transcript so the lecture text blocks can quote
// the REAL 32-bit musl output. Not part of the build; a capture aid.

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
        baseurl: path.join(SCRATCH, "images/ocaml-rootfs-flat") + "/",
        basefs: path.join(SCRATCH, "images/ocaml-fs.json"),
    },
});

// A single end-marker lets us know the whole batch is done.
const CMD = [
    "cd /root/m10",
    "make uaf >/dev/null 2>&1 && ./uaf",
    "make check_ub check_safe >/dev/null 2>&1; ./check_ub; ./check_safe",
    "make uninit >/dev/null 2>&1 && ./uninit",
    "make overflow >/dev/null 2>&1; ./overflow hello; ./overflow AAAAAAAAAAAAAAAAAAAAAAAAAAAA; echo \"exit=$?\"",
    "make heartbleed >/dev/null 2>&1 && ./heartbleed_mini",
    "make race >/dev/null 2>&1 && ./race && ./race && ./race",
    "echo M10\"\"DONE",
].join(" ; ") + "\n";

let serial = "";
let sent = false;
const t0 = Date.now();
const mark = m => process.stderr.write(`\n[${((Date.now() - t0) / 1000).toFixed(1)}s] ${m}\n`);

emulator.add_listener("emulator-started", function () {
    setTimeout(() => emulator.serial0_send("\n"), 1000);
});

emulator.add_listener("serial0-output-byte", function (byte) {
    const c = String.fromCharCode(byte);
    serial += c;
    process.stdout.write(c);

    if (!sent && serial.endsWith(":~# ")) {
        sent = true;
        mark("prompt; sending m10 demos");
        emulator.serial0_send(CMD);
    }
    if (sent && serial.includes("M10DONE")) {
        mark("m10 capture complete");
        emulator.destroy();
        process.exit(0);
    }
});

setTimeout(() => { mark("TIMEOUT"); process.exit(1); }, 10 * 60 * 1000);
