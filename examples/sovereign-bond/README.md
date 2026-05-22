# Sovereign Bond — Illustrative Asset Class

> Demonstrates how OTAS composable primitives compose into a complex financial instrument.

## Primitive Composition

```
SovereignBond = ITokenBase(Partitioned)
              + IComplianceGated
              + IHoldable
              + ISettleable
              + IMetadataAttachable
```

## Why This Asset Class

Sovereign bonds are the most demanding test case for composable token primitives because they require **all five primitives simultaneously**:

| Lifecycle Stage | Primitive Used | Why |
|----------------|---------------|-----|
| Issuance | `ITokenBase.mint` + `IMetadataAttachable.attach` | Mint with ISIN, LEI, term sheet |
| Primary Distribution | `IComplianceGated.canTransfer` + `ISettleable.initDvP` | Compliance-gated DvP delivery |
| Coupon Payment | `IHoldable.createHold` + `IHoldable.executeHold` | Escrow coupon, distribute at record date |
| Secondary Trading | `IComplianceGated.canTransfer` + `ISettleable` | Every trade is compliance-checked DvP |
| Maturity Redemption | `ITokenBase.burn` + `ISettleable.finalize` | Burn bond, pay principal atomically |

## Example: 10-Year US Treasury Bond (Tokenized)

```
Token Metadata:
  ISIN:        US91282CJL54
  LEI:         254900HROIFWPRGM1V77 (US Treasury)
  CFI:         DBFTFR (Debt / Bond / Fixed / Treasury / Fixed Rate)
  Base Type:   Fungible
  Decimals:    6 (micro-units for institutional precision)
  Coupon Rate: 4.25% semi-annual
  Maturity:    2034-11-15
```

## Key Design Decisions

1. **Coupon as Hold, not Mint**: Coupons are pre-funded into an escrow via `createHold`, then distributed via `executeHold` at the record date. This avoids minting new tokens for each coupon.

2. **Compliance at Initiation, not Settlement**: `canTransfer` is checked when `initDvP` is called, not when `finalize` executes. This prevents a scenario where compliance status changes between commitment and finalization.

3. **Maturity as Atomic DvP**: Redemption is modeled as a DvP where the bondholder delivers the bond (burn) and receives the principal (payment token transfer) atomically.
