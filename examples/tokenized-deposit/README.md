# Tokenized Deposit — Illustrative Asset Class

> Bank-issued tokenized claims on fiat deposits.

## Primitive Composition

```
TokenizedDeposit = ITokenBase(Fungible)
                 + IComplianceGated    // KYC-verified holders only
                 + ISettleable         // DvP for interbank settlement
                 + IMetadataAttachable // Issuing bank LEI, currency code
```

## Why This Asset Class

Tokenized deposits represent the simplest non-trivial asset class:
- **Fungible** — every unit is identical
- **KYC-gated** — only verified bank customers hold them
- **Interbank DvP** — settlement between institutions is atomic
- **No holds needed** — deposits don't have coupon schedules or margin requirements

This makes tokenized deposits the ideal "hello world" for OTAS primitives — complex enough to test composition, simple enough to fit in a single contract.

## Real-World Context

- **JPMorgan JPM Coin** — tokenized USD deposits for wholesale payments
- **Société Générale FORGE** — EUR tokenized deposits on Ethereum
- **MAS Project Guardian** — multi-bank tokenized deposit pilots in Singapore

## Metadata Example

```
Token Metadata:
  LEI:       7H6GLXDRUGQFU57RNE97 (JPMorgan Chase)
  Currency:  USD
  Base Type: Fungible
  Decimals:  2 (cent precision)
```

## Implementation Status

Reference implementation pending — will follow the same pattern as `SovereignBond.sol` with `IHoldable` removed.
