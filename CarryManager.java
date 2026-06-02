{
  "schemaVersion": 1,
  "id": "sct",
  "version": "1.0.0",
  "name": "Slayer Carry Tracker",
  "description": "Hypixel Skyblock slayer carry tracker. Zen-style config, boss alerts, entity highlight, carry sessions, coins tracking.",
  "authors": [],
  "license": "MIT",
  "environment": "client",
  "entrypoints": {
    "client": ["com.sct.SCTClient"]
  },
  "mixins": ["sct.mixins.json"],
  "depends": {
    "fabricloader": ">=0.15.0",
    "fabric-api": "*",
    "minecraft": "~1.21.1"
  }
}
