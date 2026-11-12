#!/usr/bin/env bash
# Builds build/kickstart.ue2: Spiffy_Ultimate 1.1.0x2 (a fork of the 1541ultimate firmware the C64 Ultimate
# ships with) + UCI palette commands + build without trademarks. The result only runs from RAM; it never
# flashes. This script never builds "kickburn" (the flashing variant).
#
# Needs: git, make, python3, a host C compiler, and a RISC-V GCC (default prefix riscv-none-elf-, e.g. the
# xPack "riscv-none-elf-gcc" 13.x). Other prefix: CROSS=riscv32-unknown-elf- ./build.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CROSS="${CROSS:-riscv-none-elf-}"
MARCH="${MARCH:-rv32i_zicsr}"          # GCC 12+ needs _zicsr; old toolchains: MARCH=rv32i
BASE=3b582da7                          # spiffycrew/Spiffy_Ultimate, branch spiffy-master-1.1.0 ("1.1.0x2")
SRC="$HERE/build/src"

command -v "${CROSS}gcc" >/dev/null || { echo "${CROSS}gcc not found (RISC-V toolchain missing)"; exit 1; }
mkdir -p "$HERE/build/bin"
ln -sf "$(command -v python3)" "$HERE/build/bin/python"       # the build calls "python"
export PATH="$HERE/build/bin:$PATH"

if [ ! -d "$SRC/.git" ]; then
  git clone --filter=blob:none https://github.com/spiffycrew/Spiffy_Ultimate.git "$SRC"
fi
cd "$SRC"
git checkout -q -B kanal7-palette "$BASE"
git submodule update --init -q
git -c user.name=build -c user.email=build@localhost am -q --keep-cr "$HERE"/patches/*.patch

# Bundled 64tass 1.53 (newer 64tass versions reject the 6502 sources). On macOS it needs _XOPEN_SOURCE.
make -C tools/64tass CFLAGS='-O2 -D_XOPEN_SOURCE=700 -D_DARWIN_C_SOURCE -DREVISION="\"1.53\""'
make -C tools SYSTEMDRIVE=C:
make -C software/6502/sidcrt                 # 6502 SID player; the app Makefile does not trigger it in a fresh tree
make -C target/libs/riscv/lwip CROSS="$CROSS" MARCH="$MARCH" AR="${CROSS}ar"   # host ar would build an empty lib
make -C target/u64ii/riscv/ultimate CROSS="$CROSS" MARCH="$MARCH"
make -C target/u64ii/riscv/kickstart CROSS="$CROSS" MARCH="$MARCH"
cp target/u64ii/riscv/kickstart/result/kickstart.app "$HERE/build/kickstart.ue2"
echo "done: $HERE/build/kickstart.ue2"
