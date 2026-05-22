# Conformance Testing Framework

> Verifies that implementations of OTAS primitives behave according to the specification,
> regardless of the target platform (Solidity, Move, Chaincode).

## Purpose

Conformance tests are **platform-independent behavioral tests**. They define:
- **Test vectors**: specific inputs and expected outputs
- **State transition assertions**: pre-conditions and post-conditions for each operation
- **Event emission checks**: which events must fire for each operation

If a Solidity implementation and a Move implementation both pass the same conformance suite,
they are **semantically equivalent** — the core OTAS guarantee.

## Structure

```
conformance/
├── README.md                              # This file
├── vectors/
│   ├── token-base.vectors.json            # ITokenBase test vectors
│   ├── compliance-gated.vectors.json      # IComplianceGated test vectors
│   ├── holdable.vectors.json              # IHoldable test vectors
│   ├── settleable.vectors.json            # ISettleable test vectors
│   └── metadata-attachable.vectors.json   # IMetadataAttachable test vectors
└── solidity/
    └── TokenBaseConformance.t.sol         # Foundry test harness for ITokenBase
```

## How Test Vectors Work

Each `.vectors.json` file contains an array of test cases. Every test case has:

```json
{
  "id": "unique-test-id",
  "description": "Human-readable description",
  "primitive": "ITokenBase | IComplianceGated | IHoldable | ...",
  "operation": "transfer | canTransfer | createHold | ...",
  "setup": { "...initial state..." },
  "input": { "...operation arguments..." },
  "expected": {
    "output": { "...return values..." },
    "stateChanges": { "...post-conditions..." },
    "events": [ { "...emitted events..." } ],
    "reverts": false
  }
}
```

Implementations in any language can:
1. Parse the JSON vectors
2. Set up the initial state described in `setup`
3. Call the operation with the given `input`
4. Assert that `output`, `stateChanges`, and `events` match `expected`

## Running Conformance Tests

### Solidity (Foundry)
```bash
cd conformance/solidity
forge test --match-contract Conformance -vvv
```

### Move (SUI)
```bash
# Future: sui move test --filter conformance
```

### Custom Implementation
Any implementation can load the JSON vectors and run assertions in its native test framework.

## Adding New Vectors

1. Add test cases to the appropriate `.vectors.json` file
2. Follow the schema: `id`, `description`, `primitive`, `operation`, `setup`, `input`, `expected`
3. Ensure both positive (success) and negative (revert/reject) cases are covered
4. Submit via PR for TSC review
