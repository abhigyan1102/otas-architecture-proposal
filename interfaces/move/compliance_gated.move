// Copyright 2026 Abhigyan Singh — Apache License 2.0
// OTAS Layer 3 — Compliance Hook Module for SUI

/// @title compliance_gated
/// @notice SUI Move implementation of the OTAS IComplianceGated interface.
///         Defines compliance hook points that production platforms fill.
///         The reference implementation always permits transfers.
module otas::compliance_gated {
    use sui::event;

    // ──────────────────────────────────────────────
    // Reason Codes (matching Solidity constants)
    // ──────────────────────────────────────────────
    const REASON_NONE: u8 = 0x00;
    const REASON_SENDER_NOT_ELIGIBLE: u8 = 0x01;
    const REASON_RECIPIENT_NOT_ELIGIBLE: u8 = 0x02;
    const REASON_AMOUNT_EXCEEDS_LIMIT: u8 = 0x03;
    const REASON_JURISDICTION: u8 = 0x04;
    const REASON_HOLDING_PERIOD: u8 = 0x05;
    const REASON_MAX_HOLDERS: u8 = 0x06;
    const REASON_CUSTOM: u8 = 0xFF;

    // ──────────────────────────────────────────────
    // Compliance Policy Object
    // ──────────────────────────────────────────────

    /// A shared compliance policy that tokens reference.
    /// Production platforms replace this with their engine.
    struct CompliancePolicy has key, store {
        id: sui::object::UID,
        /// If true, all transfers are permitted (reference impl default)
        permissive: bool,
    }

    // ──────────────────────────────────────────────
    // Events — Compliance Category
    // ──────────────────────────────────────────────

    struct TransferRestricted has copy, drop {
        from: address,
        to: address,
        amount: u64,
        reason_code: u8,
    }

    struct EligibilityChanged has copy, drop {
        account: address,
        eligible: bool,
        reason_code: u8,
    }

    // ──────────────────────────────────────────────
    // Public Functions
    // ──────────────────────────────────────────────

    /// Check if a transfer is permitted.
    /// Reference implementation: always returns true.
    public fun can_transfer(
        _policy: &CompliancePolicy,
        _from: address,
        _to: address,
        _amount: u64,
    ): (bool, u8) {
        // Reference implementation — permissive by default.
        // Production platforms override this with real compliance logic.
        (true, REASON_NONE)
    }

    /// Check if an account is eligible to hold the token.
    /// Reference implementation: always returns true.
    public fun is_eligible(
        _policy: &CompliancePolicy,
        _account: address,
    ): bool {
        true
    }

    /// Emit a transfer restriction event (called by token on rejection)
    public fun emit_restriction(
        from: address,
        to: address,
        amount: u64,
        reason_code: u8,
    ) {
        event::emit(TransferRestricted {
            from,
            to,
            amount,
            reason_code,
        });
    }
}
