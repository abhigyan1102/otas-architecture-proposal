// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title ITokenBase
 * @notice OTAS Layer 2 — Token Base Type Interface
 * @dev Every OTAS-compliant token MUST implement this interface.
 *      Defines the fundamental classification and base operations.
 *
 *      Base Types:
 *        - Fungible:     Interchangeable units (deposits, stablecoins)
 *        - NonFungible:  Unique assets (real estate, IoT devices)
 *        - Partitioned:  Fungible within tranches (structured debt)
 *        - Composite:    Bundles of other tokens (collateral baskets)
 */
interface ITokenBase {
    /// @notice Token base type classification
    enum BaseType {
        Fungible,
        NonFungible,
        Partitioned,
        Composite
    }

    // ──────────────────────────────────────────────
    // View Functions
    // ──────────────────────────────────────────────

    /// @notice Returns the base type classification of this token
    function baseType() external view returns (BaseType);

    /// @notice Returns the token name
    function name() external view returns (string memory);

    /// @notice Returns the token symbol
    function symbol() external view returns (string memory);

    /// @notice Returns the number of decimals (Fungible/Partitioned only)
    function decimals() external view returns (uint8);

    /// @notice Returns the total supply across all holders
    function totalSupply() external view returns (uint256);

    /// @notice Returns the balance of a specific account
    function balanceOf(address account) external view returns (uint256);

    // ──────────────────────────────────────────────
    // State-Changing Functions
    // ──────────────────────────────────────────────

    /// @notice Transfer tokens to a recipient
    /// @dev MUST call IComplianceGated.canTransfer if the token implements it.
    ///      MUST emit Transferred event on success.
    function transfer(address to, uint256 amount) external returns (bool);

    // ──────────────────────────────────────────────
    // Events — Lifecycle Category
    // ──────────────────────────────────────────────

    /// @notice Emitted when new tokens are minted
    event Minted(
        address indexed to,
        uint256 amount,
        bytes32 indexed operationId
    );

    /// @notice Emitted when tokens are burned
    event Burned(
        address indexed from,
        uint256 amount,
        bytes32 indexed operationId
    );

    /// @notice Emitted on every transfer (including mint and burn)
    event Transferred(
        address indexed from,
        address indexed to,
        uint256 amount
    );
}
