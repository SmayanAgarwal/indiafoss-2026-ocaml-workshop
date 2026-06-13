#!/usr/bin/env node
// v6 variant of ../make-state.mjs: boots the candidate v6 image
// (from $SCRATCH/images-v6) and saves its post-boot snapshot there.
// After this, compress:
//   zstd -19 -f $SCRATCH/images-v6/ocaml-state.bin \
//        -o $SCRATCH/images-v6/ocaml-state.bin.zst

import path from "node:path";
import fs from "node:fs";
import url from "node:url";

const __dirname = url.fileURLToPath(new URL(".", import.meta.url));
const SCRATCH = process.env.VM_SCRATCH ||
    path.join(__dirname, "..", "..", "..", "_vm-prototype");
const IMAGES = path.join(SCRATCH, "images-v6");
const { V86 } = await import(
    url.pathToFileURL(path.join(SCRATCH, "v86/build/libv86.mjs")));

const OUTPUT_FILE = path.join(IMAGES, "ocaml-state.bin");

const emulator = new V86({
    bios: { url: path.join(SCRATCH, "v86/bios/seabios.bin") },
    vga_bios: { url: path.join(SCRATCH, "v86/bios/vgabios.bin") },
    wasm_path: path.join(SCRATCH, "v86/build/v86.wasm"),
    autostart: true,
    memory_size: 512 * 1024 * 1024,
    vga_memory_size: 8 * 1024 * 1024,
    network_relay_url: "<UNUSED>",
    bzimage_initrd_from_filesystem: true,
    cmdline: "rw root=host9p rootfstype=9p rootflags=trans=virtio,cache=loose modules=virtio_pci tsc=reliable init_on_free=on",
    filesystem: {
        baseurl: path.join(IMAGES, "ocaml-rootfs-flat") + "/",
        basefs: path.join(IMAGES, "ocaml-fs.json"),
    },
});

console.log("Booting ...");

let serial_text = "";
let booted = false;
const t0 = Date.now();

emulator.add_listener("serial0-output-byte", function(byte)
{
    const c = String.fromCharCode(byte);
    process.stdout.write(c);
    serial_text += c;

    // Match the prompt suffix only: the hostname can lag the getty.
    if(!booted && serial_text.endsWith(":~# "))
    {
        booted = true;
        console.log(`\n[boot reached prompt in ${(Date.now() - t0) / 1000}s]`);

        emulator.serial0_send("sync;echo 3 >/proc/sys/vm/drop_caches\n");

        setTimeout(async function ()
            {
                const s = await emulator.save_state();
                fs.writeFile(OUTPUT_FILE, new Uint8Array(s), function(e)
                    {
                        if(e) throw e;
                        console.log("Saved as " + OUTPUT_FILE);
                        emulator.destroy();
                        process.exit(0);
                    });
            }, 10 * 1000);
    }
});
