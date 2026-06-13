#!/usr/bin/env node
// Headless end-to-end check for the CANDIDATE v6 image: restore the
// v6 snapshot from $SCRATCH/images-v6 and run the module 12
// unikernel workflow over serial:
//   1. run the pre-built bytecode unikernel (expect 4 hello lines);
//   2. edit unikernel.ml (hello -> bonjour), rebuild incrementally,
//      run again (expect bonjour lines);
//   3. mirage configure -t hvt, diff mirage/main.ml against the
//      saved unix one (expect the Solo5_os.Main.run line);
//   4. mirage configure -t unix to restore the boot state.
// Success criterion: the final M12-OK marker plus the bonjour and
// Solo5_os evidence in the serial log.

import path from "node:path";
import url from "node:url";

const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
const SCRATCH = process.env.VM_SCRATCH ||
    path.join(__dirname, "..", "..", "..", "_vm-prototype");
const IMAGES = path.join(SCRATCH, "images-v6");
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
    initial_state: { url: path.join(IMAGES, "ocaml-state.bin") },
    filesystem: {
        // node libv86 reads chunks via fs; an http baseurl would
        // silently hang the 9p filesystem here.
        baseurl: path.join(IMAGES, "ocaml-rootfs-flat") + "/",
        basefs: path.join(IMAGES, "ocaml-fs.json"),
    },
});

const CMD = "cd /root/m12/hello && ./dist/hello && " +
    "sed -i 's/\"hello\"/\"bonjour\"/' unikernel.ml && " +
    "time make build && ./dist/hello && " +
    "cp mirage/main.ml /tmp/main-unix.ml && " +
    "mirage configure -t hvt && " +
    "(diff /tmp/main-unix.ml mirage/main.ml || true) && " +
    "mirage configure -t unix && echo M12-OK\n";

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
        mark("prompt; sending m12 workflow");
        emulator.serial0_send(CMD);
    }
    if (sent && serial.includes("M12-OK") &&
        /\[application\] bonjour/.test(serial) &&
        serial.includes("Solo5_os.Main.run")) {
        mark("m12 workflow complete: unikernel rebuilt and " +
            "unix/hvt configure round-trip verified");
        emulator.destroy();
        process.exit(0);
    }
});

setTimeout(() => { mark("TIMEOUT"); process.exit(1); }, 30 * 60 * 1000);
