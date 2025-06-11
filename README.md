# 🧳 Outfit Bag Script für FiveM (ESX)

Ein leistungsstarkes Outfit-System für ESX-basierte FiveM-Server – vollständig optimiert mit **0.00ms Resmon**, konfigurierbaren Komponenten und Outfit-Sharing in Echtzeit.

---

## 🚀 Features

- 📦 Outfit-Aufbewahrung über Item (`outfitbag`)
- 👕 Outfits speichern, löschen & direkt anziehen
- 🔁 Outfit-Komponenten mit Animation ein-/ausziehbar
- 🎒 Prop-Spawn bei Benutzung der Tasche
- 🧍 Outfit-Sharing im Umkreis (mit `E`-Interaktion)
- 🧠 Speicherlimit & aktuelle Auswahl in Datenbank
- 📜 Vollständig konfigurierbar via `config.lua`
- 🔋 0.00ms Resmon im Idle

---

## ⚙️ Voraussetzungen

Dieses Script benötigt folgende Ressourcen:

- [`es_extended`](https://github.com/esx-framework/es_extended)
- [`esx_skin`](https://github.com/esx-framework/esx_skin)
- [`skinchanger`](https://github.com/esx-framework/skinchanger)
- [`oxmysql`](https://github.com/overextended/oxmysql)

---

## 🛠️ Installation

1. Stelle sicher, dass alle Abhängigkeiten installiert und gestartet sind.
2. Füge das Script in deinen `resources`-Ordner ein.
3. Starte das Script in deiner `server.cfg`:
   ```cfg
   ensure outfitbag
