# EtherBlade

**100% on-chain dynamic GameFi NFT** built with Solidity and Foundry.

No IPFS. No external metadata server. SVG artwork and JSON metadata are generated entirely inside the smart contract and served as Base64 data URIs.

As the blade levels up via `trainBlade()`, both the **visual tier** and **on-chain attributes** update automatically.

## **Live (Sepolia):** [`0x45F1514780b8065146426C11f93C0974A880687E`](https://sepolia.etherscan.io/address/0x45F1514780b8065146426C11f93C0974A880687E#code) · Verified on Etherscan

## Features

| Feature                | Implementation                                                        |
| ---------------------- | --------------------------------------------------------------------- |
| **Fully on-chain SVG** | Dynamic vector art built with Solidity string concatenation           |
| **On-chain metadata**  | OpenSea-compatible JSON encoded as `data:application/json;base64,...` |
| **Leveling system**    | `trainBlade(tokenId)` increases level + attack power                  |
| **Visual tiers**       | Novice (1–9) · Adept (10–19) · Legendary (20+)                        |
| **Security**           | Custom errors, ownership checks, max level cap                        |
| **Tooling**            | Foundry unit/integration tests, deploy scripts, Makefile              |

**Core contract coverage: 100%** (lines, statements, branches, functions)

---

## How it works

1. User calls `mintBlade()` → receives Level 1 Novice blade (10 ATK).
2. Owner calls `trainBlade(tokenId)` → level +1, attack +15.
3. `tokenURI(tokenId)` rebuilds:
   - SVG colors / glow / rank title from current level
   - JSON attributes: Rank, Level, Attack Power
4. Marketplaces render the data URI directly — nothing off-chain required.

### Tier table

| Level | Rank      | Blade color      |
| ----- | --------- | ---------------- |
| 1–9   | Novice    | Silver `#C0C0C0` |
| 10–19 | Adept     | Cyan `#00E5FF`   |
| 20+   | Legendary | Gold `#FFD700`   |

---

## Architecture

```text
ether-blade/
├── src/
│   └── EtherBlade.sol
├── script/
│   ├── DeployEtherBlade.s.sol
│   ├── HelperConfig.s.sol
│   └── Interactions.s.sol
└── test/
    ├── unit/
    └── integration/
```

## Quickstart

### Setup

```bash
git clone <your-repo-url>
cd ether-blade
make install
make build
make test
```

### Environment

```bash
SEPOLIA_RPC_URL=...
PRIVATE_KEY=...
ETHERSCAN_API_KEY=...
```

```bash
source .env
```

## Tests & coverage

```bash
make test
make test-unit
make test-integration
make coverage
```

| File                 | Lines    | Statements | Branches | Funcs    |
| -------------------- | -------- | ---------- | -------- | -------- |
| `src/EtherBlade.sol` | **100%** | **100%**   | **100%** | **100%** |

## Deploy

### Local

```bash
make anvil          # terminal 1
make deploy         # terminal 2
make mint
make train
```

### Sepolia

```bash
make deploy-sepolia
make mint ARGS="--network sepolia"
make train ARGS="--network sepolia"
```

## Security notes

- Only the token owner can call trainBlade.
- Non-existent token IDs revert with custom errors.
- Max level capped at 100.
- Metadata and art are pure view computation — no external calls in tokenURI.

Educational / portfolio project. Audit before mainnet use with real value.

## License

MIT
