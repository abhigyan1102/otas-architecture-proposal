// Copyright 2026 Abhigyan Singh — Apache License 2.0
// OTAS Layer 2 — Token Base Module for SUI

/// @title token_base
/// @notice SUI Move implementation of the OTAS ITokenBase interface.
///         Semantically equivalent to the Solidity ITokenBase.sol.
module otas::token_base {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;

    // ──────────────────────────────────────────────
    // Constants — Base Type Classification
    // ──────────────────────────────────────────────
    const FUNGIBLE: u8 = 0;
    const NON_FUNGIBLE: u8 = 1;
    const PARTITIONED: u8 = 2;
    const COMPOSITE: u8 = 3;

    // ──────────────────────────────────────────────
    // Error Codes
    // ──────────────────────────────────────────────
    const E_INSUFFICIENT_BALANCE: u64 = 1;
    const E_INVALID_AMOUNT: u64 = 2;

    // ──────────────────────────────────────────────
    // Core Object — Token
    // ──────────────────────────────────────────────

    /// A fungible token balance owned by an address.
    /// In SUI's object model, each balance is a distinct owned object.
    struct Token<phantom T> has key, store {
        id: UID,
        base_type: u8,
        balance: u64,
    }

    /// Shared object tracking global supply metadata.
    struct TokenRegistry<phantom T> has key {
        id: UID,
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        base_type: u8,
        total_supply: u64,
    }

    // ──────────────────────────────────────────────
    // Events — Lifecycle Category
    // Semantically equivalent to Solidity events
    // ──────────────────────────────────────────────

    struct Minted has copy, drop {
        to: address,
        amount: u64,
        operation_id: vector<u8>,
    }

    struct Burned has copy, drop {
        from: address,
        amount: u64,
        operation_id: vector<u8>,
    }

    struct Transferred has copy, drop {
        from: address,
        to: address,
        amount: u64,
    }

    // ──────────────────────────────────────────────
    // Public Functions
    // ──────────────────────────────────────────────

    /// Create a new token registry (called once at module publish)
    public fun create_registry<T>(
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        base_type: u8,
        ctx: &mut TxContext,
    ): TokenRegistry<T> {
        TokenRegistry<T> {
            id: object::new(ctx),
            name,
            symbol,
            decimals,
            base_type,
            total_supply: 0,
        }
    }

    /// Mint new tokens to an address
    public fun mint<T>(
        registry: &mut TokenRegistry<T>,
        amount: u64,
        operation_id: vector<u8>,
        ctx: &mut TxContext,
    ): Token<T> {
        assert!(amount > 0, E_INVALID_AMOUNT);

        registry.total_supply = registry.total_supply + amount;

        let recipient = tx_context::sender(ctx);
        event::emit(Minted {
            to: recipient,
            amount,
            operation_id,
        });

        Token<T> {
            id: object::new(ctx),
            base_type: registry.base_type,
            balance: amount,
        }
    }

    /// Get the balance of a token object
    public fun balance<T>(token: &Token<T>): u64 {
        token.balance
    }

    /// Get the base type of a token
    public fun base_type<T>(token: &Token<T>): u8 {
        token.base_type
    }

    /// Split a token — creates a new token with `amount` and reduces the original
    public fun split<T>(
        token: &mut Token<T>,
        amount: u64,
        ctx: &mut TxContext,
    ): Token<T> {
        assert!(token.balance >= amount, E_INSUFFICIENT_BALANCE);
        token.balance = token.balance - amount;

        Token<T> {
            id: object::new(ctx),
            base_type: token.base_type,
            balance: amount,
        }
    }

    /// Merge two tokens of the same type
    public fun merge<T>(token: &mut Token<T>, other: Token<T>) {
        let Token { id, base_type: _, balance } = other;
        object::delete(id);
        token.balance = token.balance + balance;
    }
}
