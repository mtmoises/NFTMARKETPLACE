# 🛒 Decentralized NFT Marketplace

A secure, gas-optimized decentralized marketplace smart contract for ERC-721 non-fungible tokens, built with **Solidity 0.8.24** and rigorously tested using **Foundry**. 

This protocol allows users to list NFTs, update or cancel listings securely, and execute atomic buy orders with native Ether while protecting against common edge cases and failed transfer vectors.

---

## 📌 Architecture & Features

- **Decentralized Listing Engine:** Enables users to list their ERC-721 tokens specifying custom token addresses, IDs, and minimum prices in native ETH.
- **Listing Lifecycle Management:** Includes complete logic for listing creation, price validation, listing cancellation, and secure purchasing.
- **Robust Access & Ownership Controls:** Strictly validates that only the true owner of an NFT can list it, and only the listing owner can cancel it.
- **Atomic Purchases & Safe Transfers:** Executes secure peer-to-peer transfers utilizing safe checks, preventing incorrect payment values and handling fund distributions safely.
- **Comprehensive Foundry Test Suite:** Features extensive unit testing, covering edge cases such as zero-price reverts, unauthorized cancellations, incorrect payment rejections, and forced recipient failure simulations using low-level state manipulation (`vm.etch`).

---

## 🛠 Tech Stack & Tools

- **Language:** Solidity `0.8.24`
- **Framework:** Foundry (Forge & Cast)
- **Libraries:** OpenZeppelin Contracts (`ERC721`)
- **Target Network:** EVM Compatible Chains

---

## 🚀 Smart Contract Overview

### Core Functions

1. **`listNFT(address nftAddress_, uint256 tokenId_, uint256 price_)`**
   - Lists an NFT for sale. Verifies ownership, validates that the price is greater than zero, and records the listing state.

2. **`cancelList(address nftAddress_, uint256 tokenId_)`**
   - Allows the original listing owner to cancel an active market listing.

3. **`buyNFT(address nftAddress_, uint256 tokenId_)`**
   - External payable function that processes purchases, verifies correct ETH amounts, transfers funds to the seller, and safely transfers the NFT to the buyer.

---

## ⚡ Quickstart & Testing (Foundry)

### 1. Clone Repository & Install Dependencies
```bash
git clone [https://github.com/mtmoises/nft-marketplace.git](https://github.com/mtmoises/nft-marketplace.git)
cd nft-marketplace
forge install

```shell
$ forge --help
$ anvil --help
$ cast --help
```
