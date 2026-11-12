# Palette commands for the C64 Ultimate (RAM-only firmware)

*Deutsch: [LIESMICH.md](LIESMICH.md)*

The C64 Ultimate ships with firmware 1.1.0, which is based on the Ultimate firmware 3.14. The palette commands of the
Ultimate Command Interface (UCI) only arrived with 3.15, so programs that set their own colours (for example Upic
pictures) cannot do that on a C64 Ultimate yet.

`kickstart.ue2` starts a firmware **with** these commands. It runs **from RAM only**: nothing is flashed, the FPGA core
and the ESP32 are not touched. After switching the machine off and on again, the original firmware runs as before.

It was made for the game [KANAL 7](https://kanal7.8bitcavern.de), but any program can use it.

## What is added

| Command | Bytes | Reply |
| --- | --- | --- |
| GET_PALETTE | `$04 $51` | 48 bytes (16 × R, G, B) |
| SET_PALETTE | `$04 $52` + 48 bytes (16 × R, G, B) | `00,OK` |
| SET_PALETTE_COLOR | `$04 $53` index R G B | `00,OK` |
| RESET_PALETTE | `$04 $54` | `00,OK` |

Command format and replies are the same as in Ultimate firmware 3.15 (invalid parameters: `81,INVALID PARAMS`).
To find out whether the commands are available, send `SET_PALETTE_COLOR` once: the original firmware 1.1.0 answers
`21,UNKNOWN COMMAND`.

## Requirements

- C64 Ultimate with firmware **1.1.0** (FPGA **122**, ESP32 firmware **1.11**). The loader checks this; if something
  does not match, it shows a message and restarts the machine after 5 seconds without changing anything.

## Usage

1. Copy `kickstart.ue2` (from [Releases](../../releases)) to a USB stick.
2. On the C64 Ultimate open the file browser, select `kickstart.ue2` and choose **Run Update**.
3. The loader shows FPGA, ESP32 and checksum. Confirm the question with **Yes**.
4. The firmware starts from RAM. Now start your program.
5. **Back to the original firmware:** switch the machine off and on again.

You have to start `kickstart.ue2` again after every power-on.

## What else is in it

The base is [Spiffy_Ultimate](https://github.com/spiffycrew/Spiffy_Ultimate) 1.1.0x2 by Spiffy Crew, a fork of the
open-source [1541ultimate firmware](https://github.com/GideonZ/1541ultimate) by Gideon Zweijtzer on which the C64
Ultimate firmware is based. It contains the RAM loader ("Kickstart") and Spiffy Crew's improvements (hotkeys, menu
and file browser features, see their README). On top of that, two patches in [`patches/`](patches):

- `0001-uci-palette-commands.patch` – the four palette commands, taken from 1541ultimate 3.15.
- `0002-build-without-trademarks.patch` – builds the variant without trademarks and branding.

Differences you may notice compared to the original firmware: menus and texts without trademarks, Spiffy Crew's
features, and the REST API reports the product as `Ultimate 64-II` instead of `C64 Ultimate`. The UCI identification
(`GET_HWINFO`) is unchanged (`ULTIMATE 64`).

## Tested

- UE2 emulator (firmware binary run directly): the palette commands are accepted (0 of 93 rejected) and change the
  picture; the original firmware 1.1.0 rejects all of them.
- C64 Ultimate (FPGA 122, core 1.49): the same palette patch on the C64 Ultimate 1.1.0 source base (commit `7b628eb1`)
  with the Kickstart loader ran on the machine, including a complete game of KANAL 7 with its own colours, online
  high score and two-player game.
- This release build (Spiffy 1.1.0x2 base, without trademarks) on the C64 Ultimate: the loader accepted the machine
  (FPGA 122, ESP32 1.11), REST reported `1.1.0x2`, a palette test sent 71 SET_PALETTE_COLOR commands with 0 rejected,
  and KANAL 7's start program detected the C64 Ultimate with palette commands.

## Building

Needs git, make, python3, a host C compiler and a RISC-V GCC (tested with the xPack `riscv-none-elf-gcc` 13.4.0 on
macOS arm64):

```
export PATH=/path/to/xpack-riscv-none-elf-gcc/bin:$PATH
./build.sh
```

The script clones Spiffy_Ultimate, checks out commit `3b582da7`, applies the patches and writes `build/kickstart.ue2`.
It never builds the flashing variant (`kickburn`).

## Please note

- Not affiliated with or endorsed by Commodore, Gideon Zweijtzer or Spiffy Crew. "C64 Ultimate" is used only to
  describe the hardware.
- No warranty. The firmware only runs from RAM and the loader does not write to flash, but use it at your own risk.
  Commodore has said it will not block third-party firmware, but does not cover damage caused by it.
- Like the original firmware, the firmware image contains the C64 system ROMs (BASIC, KERNAL, character set). They
  are not covered by the GPL.

## License

GPL-3.0, like 1541ultimate and Spiffy_Ultimate (see [LICENSE](LICENSE)). The complete source code of each release is
attached to the release as an archive; it can also be rebuilt from this repository with `build.sh`.
