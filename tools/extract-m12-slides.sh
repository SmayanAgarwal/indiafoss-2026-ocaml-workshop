#!/usr/bin/env bash
# Extract images from KC's Jan 2025 IIT Madras unikernels deck
# (_references/mirage_iitm_jan_2025.pdf, gitignored) and curate the
# subset used by the M12 lectures into assets/m12/figures/.
#
# Staging output under _references/m12-slide-images/ is gitignored;
# only the curated, renamed copies in assets/ are committed.
#
# Re-runnable: wipes and rebuilds the staging dir, then overwrites
# the curated copies.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PDF="$REPO_ROOT/_references/mirage_iitm_jan_2025.pdf"
STAGE="$REPO_ROOT/_references/m12-slide-images"
OUT="$REPO_ROOT/assets/m12/figures"

[ -f "$PDF" ] || { echo "missing $PDF (local-only source deck)"; exit 1; }
command -v pdfimages >/dev/null || { echo "needs poppler (brew install poppler)"; exit 1; }
command -v magick >/dev/null || { echo "needs imagemagick"; exit 1; }

rm -rf "$STAGE"
mkdir -p "$STAGE/raw" "$STAGE/pages" "$OUT"

# 1. All embedded rasters, page-tagged: raw/img-PPP-NNN.{jpg,png,...}
pdfimages -all -p "$PDF" "$STAGE/raw/img"

# 2. Page renders for vector compositions we crop below.
for p in 6 24 34; do
  pdftoppm -png -r 200 -f "$p" -l "$p" "$PDF" "$STAGE/pages/page"
done

# pick RAW_GLOB DEST: copy one embedded raster (content layer; the
# paired *-mask/frame layers are deliberately skipped) to assets.
pick () {
  local src dest="$2"
  src=$(ls "$STAGE"/raw/$1 2>/dev/null | head -1)
  [ -n "$src" ] || { echo "no match for $1"; exit 1; }
  case "$src" in
    *.jpg) cp "$src" "$OUT/$dest" ;;
    *) magick "$src" "$OUT/$dest" ;;
  esac
  echo "  $dest  <-  $(basename "$src")"
}

echo "curating into assets/m12/figures/:"
pick 'img-005-007.*'  slide-05-kernel-loc-chart.png
pick 'img-008-010.*'  slide-08-ingredients.jpg
pick 'img-017-016.*'  slide-17-xen-paper.png
pick 'img-020-023.*'  slide-20-microsoft-70pct.png
pick 'img-020-026.*'  slide-20-chromium-memory-safety.png
pick 'img-021-029.*'  slide-21-android-vulns.png
pick 'img-021-030.*'  slide-21-fish-in-a-barrel.png
pick 'img-022-031.*'  slide-22-cisa-roadmaps.png
pick 'img-022-034.*'  slide-22-white-house.png
pick 'img-025-065.*'  slide-25-gc-pacing.png
pick 'img-026-066.*'  slide-26-eio-webserver.png
pick 'img-027-067.*'  slide-27-salad.jpg
pick 'img-029-069.*'  slide-29-tls-paper.png
pick 'img-033-077.*'  slide-33-hello-unix-functors.png
pick 'img-034-079.*'  slide-34-hello-hvt-functors.png
pick 'img-036-087.*'  slide-36-mirage-io-host-functors.png
pick 'img-037-089.*'  slide-37-mirage-io-direct-functors.png
pick 'img-038-091.*'  slide-38-mirage-io-direct-zoom.png
pick 'img-041-092.*'  slide-41-bitcoin-pinata.png
pick 'img-042-093.*'  slide-42-nethsm.png
pick 'img-043-095.*'  slide-43-docker-for-mac.png

# 3. Crops from page renders (geometry in px at 200 dpi on a
#    1280x720pt page => 3556x2000 px render).
# OCaml industry/projects logo collage band (slide 24).
magick "$STAGE/pages/page-24.png" -crop 2520x570+520+820 +repage \
  "$OUT/slide-24-ocaml-industry.png"
echo "  slide-24-ocaml-industry.png  <-  page-24.png crop"
# Solo5/KVM architecture mini-diagram, right half of slide 34.
magick "$STAGE/pages/page-34.png" -crop 1500x720+1900+370 +repage \
  "$OUT/slide-34-solo5-hvt-arch.png"
echo "  slide-34-solo5-hvt-arch.png  <-  page-34.png crop"
# Monolithic-OS iceberg figure (photo + labels + TCB callout),
# cropped to the content span: label left edge to callout right
# edge, no slide margins (they squeezed the photo on the slide).
magick "$STAGE/pages/page-06.png" -crop 2680x1465+778+480 +repage \
  "$OUT/slide-06-iceberg.png"
echo "  slide-06-iceberg.png  <-  page-06.png crop"

echo "done."
