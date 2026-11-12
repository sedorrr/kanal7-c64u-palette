# Palettenbefehle für den C64 Ultimate (Firmware nur im RAM)

*English: [README.md](README.md)*

Der C64 Ultimate wird mit der Firmware 1.1.0 ausgeliefert. Sie beruht auf der Ultimate-Firmware 3.14. Die
Palettenbefehle der Befehlsschnittstelle (UCI) kamen erst mit 3.15. Programme, die eigene Farben setzen (zum Beispiel
Upic-Bilder), können das auf dem C64 Ultimate deshalb noch nicht.

`kickstart.ue2` startet eine Firmware **mit** diesen Befehlen. Sie läuft **nur im RAM**: Es wird nichts geflasht,
FPGA-Kern und ESP32 bleiben unberührt. Nach dem Aus- und Einschalten läuft wieder die ursprüngliche Firmware.

Entstanden ist sie für das Spiel [KANAL 7](https://kanal7.8bitcavern.de), nutzen kann sie aber jedes Programm.

## Was dazukommt

| Befehl | Bytes | Antwort |
| --- | --- | --- |
| GET_PALETTE | `$04 $51` | 48 Byte (16 × R, G, B) |
| SET_PALETTE | `$04 $52` + 48 Byte (16 × R, G, B) | `00,OK` |
| SET_PALETTE_COLOR | `$04 $53` Platz R G B | `00,OK` |
| RESET_PALETTE | `$04 $54` | `00,OK` |

Aufbau und Antworten wie in der Ultimate-Firmware 3.15 (falsche Werte: `81,INVALID PARAMS`). Ob die Befehle da sind,
erfährt ein Programm mit einem einzelnen `SET_PALETTE_COLOR`: Die ursprüngliche Firmware 1.1.0 antwortet
`21,UNKNOWN COMMAND`.

## Voraussetzung

- C64 Ultimate mit Firmware **1.1.0** (FPGA **122**, ESP32-Firmware **1.11**). Der Lader prüft das. Passt etwas nicht,
  zeigt er eine Meldung und startet das Gerät nach 5 Sekunden neu, ohne etwas zu ändern.

## Benutzung

1. `kickstart.ue2` (unter [Releases](../../releases)) auf einen USB-Stick kopieren.
2. Am C64 Ultimate den Dateibrowser öffnen, `kickstart.ue2` wählen und **Run Update** nehmen.
3. Der Lader zeigt FPGA, ESP32 und Prüfsumme. Die Frage mit **Yes** bestätigen.
4. Die Firmware startet aus dem RAM. Jetzt das eigene Programm starten.
5. **Zurück zur ursprünglichen Firmware:** Gerät aus- und wieder einschalten.

Nach jedem Einschalten muss `kickstart.ue2` neu gestartet werden.

## Was sonst noch drin ist

Grundlage ist [Spiffy_Ultimate](https://github.com/spiffycrew/Spiffy_Ultimate) 1.1.0x2 der Spiffy Crew, ein Fork der
quelloffenen [1541ultimate-Firmware](https://github.com/GideonZ/1541ultimate) von Gideon Zweijtzer, auf der die
Firmware des C64 Ultimate beruht. Er enthält den RAM-Lader („Kickstart“) und die Verbesserungen der Spiffy Crew
(Tastenkürzel, Menü- und Dateibrowser-Funktionen, siehe deren README). Darauf kommen zwei Patches aus
[`patches/`](patches):

- `0001-uci-palette-commands.patch` – die vier Palettenbefehle, übernommen aus 1541ultimate 3.15.
- `0002-build-without-trademarks.patch` – baut die Fassung ohne Markenzeichen und Branding.

Was gegenüber der ursprünglichen Firmware auffallen kann: Menüs und Texte ohne Markenzeichen, die Funktionen der
Spiffy Crew, und die REST-Schnittstelle nennt das Gerät `Ultimate 64-II` statt `C64 Ultimate`. Die UCI-Kennung
(`GET_HWINFO`) bleibt gleich (`ULTIMATE 64`).

## Geprüft

- UE2-Emulator (Firmware direkt gestartet): Die Palettenbefehle werden angenommen (0 von 93 abgelehnt) und färben das
  Bild um; die ursprüngliche Firmware 1.1.0 lehnt alle ab.
- C64 Ultimate (FPGA 122, Core 1.49): Derselbe Palettenpatch auf der Quellgrundlage des C64 Ultimate 1.1.0 (Commit
  `7b628eb1`) mit dem Kickstart-Lader lief am Gerät, darunter ein ganzes Spiel KANAL 7 in eigenen Farben, mit
  Online-Bestenliste und Spiel zu zweit.
- Dieser Release-Bau (Grundlage Spiffy 1.1.0x2, ohne Markenzeichen) am C64 Ultimate: Der Lader nahm das Gerät an
  (FPGA 122, ESP32 1.11), REST meldete `1.1.0x2`, ein Palettentest schickte 71 SET_PALETTE_COLOR, 0 abgelehnt, und das
  Startprogramm von KANAL 7 erkannte den C64 Ultimate mit Palettenbefehlen.

## Bauen

Nötig sind git, make, python3, ein C-Compiler für den Rechner und ein RISC-V-GCC (geprüft mit dem xPack
`riscv-none-elf-gcc` 13.4.0 auf macOS arm64):

```
export PATH=/pfad/zu/xpack-riscv-none-elf-gcc/bin:$PATH
./build.sh
```

Das Skript holt Spiffy_Ultimate, setzt auf Commit `3b582da7`, spielt die Patches ein und schreibt
`build/kickstart.ue2`. Die flashende Variante (`kickburn`) baut es nie.

## Bitte beachten

- Kein Angebot von Commodore, Gideon Zweijtzer oder der Spiffy Crew und von ihnen nicht unterstützt. „C64 Ultimate“
  steht hier nur zur Beschreibung der Hardware.
- Keine Gewährleistung. Die Firmware läuft nur im RAM, und der Lader schreibt nicht ins Flash. Die Nutzung geschieht
  trotzdem auf eigenes Risiko. Commodore will fremde Firmware nicht sperren, kommt aber für Schäden dadurch nicht auf.
- Wie die ursprüngliche Firmware enthält auch diese die Systemroms des C64 (BASIC, KERNAL, Zeichensatz). Für sie gilt
  die GPL nicht.

## Lizenz

GPL-3.0, wie 1541ultimate und Spiffy_Ultimate (siehe [LICENSE](LICENSE)). Der vollständige Quellcode jedes Releases
hängt als Archiv am Release; mit `build.sh` lässt er sich auch aus diesem Repository neu bauen.
