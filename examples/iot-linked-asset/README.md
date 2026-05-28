# IoT-Linked Asset — Illustrative Asset Class

> Tokens whose state depends on real-world data feeds.

## Primitive Composition

```
IoTLinkedAsset = ITokenBase(NonFungible)
              + IComplianceGated        // Authorized operators only
              + IMetadataAttachable     // Device ID, oracle feed, data hash
```

## Why This Asset Class

IoT-linked assets test the OTAS architecture at its boundaries:
- **NonFungible** — each asset is unique (a specific sensor, vehicle, or property)
- **Oracle-dependent metadata** — token state changes based on external data feeds
- **No settlement primitives** — these assets are typically not traded via DvP
- **Compliance = authorization** — "who can operate this device" rather than "who can invest"

This asset class validates that OTAS primitives are truly composable — you can use `IMetadataAttachable` without `ISettleable`, and `IComplianceGated` can model operational authorization, not just investor eligibility.

## Real-World Context

- **IoTeX** — machine-identity tokens linking IoT devices to on-chain state
- **Supply chain provenance** — tokenized cargo with GPS/temperature data
- **Carbon credits** — tokens linked to IoT sensor readings for emissions monitoring

## Metadata Example

```
Token Metadata:
  Device ID:     0x7f3a...4b2c (hardware fingerprint)
  Oracle Feed:   Chainlink Automation keeper address
  Data Hash:     SHA-256 of latest sensor reading
  Extensions:    { "sensor_type": "temperature", "unit": "celsius", "frequency_sec": 300 }
```

## Implementation Status

Reference implementation will follow after the whitepaper and specification phases are complete (see [ROADMAP.md](../../ROADMAP.md) — Phase 4). The design above documents the intended primitive composition to guide specification work.
