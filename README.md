# 🧳 Outfit Bag Script for FiveM (ESX)

A powerful outfit system for ESX-based FiveM servers – fully optimized with **0.00ms resmon**, customizable components, and real-time outfit sharing.

---

## 🚀 Features

- 📦 Store outfits using an item (`outfitbag`)
- 👕 Save, delete & instantly equip outfits
- 🔁 Equip/remove clothing components with animations
- 🎒 Spawn prop when using the bag
- 🧠 Save limit & current outfit stored in the database
- 📜 Fully configurable via `config.lua`
- 🔋 0.00ms resmon while idle

---

## ⚙️ Requirements

This script requires the following resources:

- [`es_extended`](https://github.com/esx-framework/es_extended)
- [`esx_skin`](https://github.com/esx-framework/esx_skin)
- [`skinchanger`](https://github.com/esx-framework/skinchanger)
- [`oxmysql`](https://github.com/overextended/oxmysql)

---

## 🛠️ Installation

1. Make sure all required dependencies are installed and started.
2. Add the script to your `resources` folder.
3. Start the script in your `server.cfg`:
   ```cfg
   ensure outfitbag
