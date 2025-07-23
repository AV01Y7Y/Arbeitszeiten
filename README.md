# Arbeitszeiten
Dieses PowerShell-Script liest die Windows Ereignisanzeige für den Zeitraum des aktuellen Monats und ermittelt für die Tage Mo-Fr das jeweils erste und letzte Ereignis. Die Zeitstempel werden anschließend auf 5 Minuten gerundet, bevor letztendlich eine Tabelle mit den aktiven Zeiten ausgegeben wird.

## Usage

`.\Arbeitszeiten.ps1` - Gibt die Zeiten Minutengenau zurück.

`.\Arbeitszeiten.ps1 -RoundTimes` - Rundet die Zeiten auf 5 Minuten genau.