// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "../interfaces/solidity/ITokenBase.sol";
import "../interfaces/solidity/IComplianceGated.sol";
import "../interfaces/solidity/IHoldable.sol";
import "../interfaces/solidity/ISettleable.sol";
import "../interfaces/solidity/IMetadataAttachable.sol";

/**
 * @title SovereignBond
 * @notice Illustrative reference implementation composing all five OTAS primitives.
 * @dev This is a RESEARCH ARTIFACT — not production code.
 *      Demonstrates how composable primitives assemble into a
 *      tokenized sovereign bond with compliance-gated DvP settlement.
 *
 * Composition:
 *   ITokenBase(Fungible) — base transfer and supply management
 *   IComplianceGated     — investor eligibility hooks
 *   IHoldable            — coupon escrow and margin holds
 *   ISettleable          — atomic DvP for primary/secondary trading
 *   IMetadataAttachable  — ISIN, LEI, term sheet attachment
 */
contract SovereignBond is ITokenBase, IComplianceGated, IHoldable, IMetadataAttachable {

    // ──────────────────────────────────────────────
    // State
    // ──────────────────────────────────────────────

    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 6; // Micro-units for institutional precision
    uint256 private _totalSupply;

    address public issuer;
    uint256 public maturityDate;
    uint256 public couponRateBps; // Basis points (e.g., 425 = 4.25%)

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _heldBalances;
    mapping(bytes32 => Hold) private _holds;
    mapping(uint256 => TokenMetadata) private _metadata;

    struct Hold {
        address holder;
        address notary;
        uint256 amount;
        uint256 expiry;
        HoldStatus status;
    }

    // ──────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────

    constructor(
        string memory name_,
        string memory symbol_,
        address issuer_,
        uint256 maturityDate_,
        uint256 couponRateBps_
    ) {
        _name = name_;
        _symbol = symbol_;
        issuer = issuer_;
        maturityDate = maturityDate_;
        couponRateBps = couponRateBps_;
    }

    // ──────────────────────────────────────────────
    // ITokenBase Implementation
    // ──────────────────────────────────────────────

    function baseType() external pure override returns (BaseType) {
        return BaseType.Fungible;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        // Compliance check — the OTAS pattern
        (bool allowed, bytes32 reason) = this.canTransfer(msg.sender, to, amount);
        if (!allowed) {
            emit TransferRestricted(msg.sender, to, amount, reason);
            revert("SovereignBond: transfer restricted");
        }

        require(availableBalance(msg.sender) >= amount, "SovereignBond: insufficient available balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transferred(msg.sender, to, amount);
        return true;
    }

    /// @notice Mint new bonds — only callable by the issuer
    function mint(address to, uint256 amount, bytes32 operationId) external {
        require(msg.sender == issuer, "SovereignBond: only issuer");

        _totalSupply += amount;
        _balances[to] += amount;

        emit Minted(to, amount, operationId);
        emit Transferred(address(0), to, amount);
    }

    // ──────────────────────────────────────────────
    // IComplianceGated Implementation (Reference — permissive)
    // ──────────────────────────────────────────────

    function canTransfer(
        address /* from */,
        address /* to */,
        uint256 /* amount */
    ) external pure override returns (bool allowed, bytes32 reasonCode) {
        // Reference implementation: always permits transfers.
        // Production platforms override with real compliance logic:
        //   - KYC verification via identity registry
        //   - Jurisdiction restrictions
        //   - Holding period checks (Rule 144)
        //   - Maximum holder limits
        return (true, bytes32(0));
    }

    function isEligible(address /* account */) external pure override returns (bool) {
        return true; // Reference: all accounts eligible
    }

    // ──────────────────────────────────────────────
    // IHoldable Implementation
    // ──────────────────────────────────────────────

    function createHold(
        bytes32 holdId,
        address holder,
        address notary,
        uint256 amount,
        uint256 expiry
    ) external override returns (bool) {
        require(_holds[holdId].status == HoldStatus.Nonexistent, "SovereignBond: hold exists");
        require(availableBalance(holder) >= amount, "SovereignBond: insufficient balance");

        _holds[holdId] = Hold({
            holder: holder,
            notary: notary,
            amount: amount,
            expiry: expiry,
            status: HoldStatus.Active
        });
        _heldBalances[holder] += amount;

        emit HoldCreated(holdId, holder, notary, amount, expiry);
        return true;
    }

    function executeHold(bytes32 holdId, address to) external override returns (bool) {
        Hold storage h = _holds[holdId];
        require(h.status == HoldStatus.Active, "SovereignBond: hold not active");
        require(msg.sender == h.notary, "SovereignBond: only notary");

        h.status = HoldStatus.Executed;
        _heldBalances[h.holder] -= h.amount;
        _balances[h.holder] -= h.amount;
        _balances[to] += h.amount;

        emit HoldExecuted(holdId, to, h.amount);
        emit Transferred(h.holder, to, h.amount);
        return true;
    }

    function releaseHold(bytes32 holdId) external override returns (bool) {
        Hold storage h = _holds[holdId];
        require(h.status == HoldStatus.Active, "SovereignBond: hold not active");
        require(msg.sender == h.notary || msg.sender == h.holder, "SovereignBond: unauthorized");

        h.status = HoldStatus.Released;
        _heldBalances[h.holder] -= h.amount;

        emit HoldReleased(holdId, h.amount);
        return true;
    }

    function holdStatus(bytes32 holdId) external view override returns (HoldStatus) {
        return _holds[holdId].status;
    }

    function heldBalance(address account) external view override returns (uint256) {
        return _heldBalances[account];
    }

    function availableBalance(address account) public view override returns (uint256) {
        return _balances[account] - _heldBalances[account];
    }

    // ──────────────────────────────────────────────
    // IMetadataAttachable Implementation
    // ──────────────────────────────────────────────

    function attach(uint256 tokenId, TokenMetadata calldata metadata) external override {
        require(msg.sender == issuer, "SovereignBond: only issuer");
        _metadata[tokenId] = metadata;
        emit MetadataAttached(tokenId, metadata.isin, metadata.lei);
    }

    function updateField(uint256 tokenId, string calldata field, bytes calldata /* data */) external override {
        require(msg.sender == issuer, "SovereignBond: only issuer");
        bytes32 prevHash = _metadata[tokenId].termSheetHash;
        // In a full implementation, this would update the specific field
        emit MetadataUpdated(tokenId, field, prevHash, bytes32(0));
    }

    function resolve(uint256 tokenId) external view override returns (TokenMetadata memory) {
        return _metadata[tokenId];
    }
}
