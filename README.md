# Smart-Contract-Development

## 1) Project overview
Educational overcollateralized DeFi lending protocol built with Solidity and Foundry. Users deposit supported ERC20 collateral and mint a USD-pegged stablecoin (`DSC`) subject to health-factor constraints.

> **Important:** This project is intentionally educational and security-focused. It is **not** production-ready.

## 2) Architecture
- `DecentralizedStableCoin.sol`: ERC20 stablecoin, mint/burn restricted to DSCEngine ownership.
- `DSCEngine.sol`: core accounting, collateral management, mint/burn, redemption, liquidation, health-factor enforcement.
- `OracleLib.sol`: stale/invalid oracle safeguards for Chainlink-style feeds.
- `HelperConfig.s.sol`: network config for Anvil/Sepolia and local mock deployment.
- `DeployDSC.s.sol`: full protocol deployment flow.

## 3) How the protocol works
1. Deposit supported collateral.
2. Mint DSC up to collateral constraints.
3. Repay debt by burning DSC.
4. Redeem collateral if health factor remains safe.
5. If health factor falls below threshold, third parties can liquidate debt for discounted collateral.

## 4) Contract explanations
### DecentralizedStableCoin
- OpenZeppelin-style ERC20 + Ownable access control.
- `mint(to, amount)` and `burn(amount)` are owner-only.

### DSCEngine
- Manages collateral and debt with custom errors and events.
- Uses checks-effects-interactions and non-reentrancy guards.
- Uses price feeds with stale-price checks.

## 5) Installation
```bash
git clone <repo-url>
cd Smart-Contract-Development
```

## 6) Local Anvil setup
```bash
anvil
```

## 7) Running tests
```bash
forge test
```

## 8) Running fuzz tests
```bash
forge test --match-test testFuzz
```

## 9) Running invariant tests
```bash
forge test --match-path test/invariant/* -vvvv
```

## 10) Deployment instructions
```bash
forge script script/DeployDSC.s.sol:DeployDSC --rpc-url http://127.0.0.1:8545 --broadcast
```

## 11) Sepolia deployment instructions
1. Copy `.env.example` to `.env`
2. Set `PRIVATE_KEY` and `SEPOLIA_RPC_URL`
3. Run:
```bash
forge script script/DeployDSC.s.sol:DeployDSC --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

## 12) Security assumptions
- Reliable and honest oracle data providers.
- Liquidators are available during volatility.
- Collateral tokens are standards-compliant ERC20s.

## 13) Known limitations
- No governance or parameter timelock.
- No rate model / interest accrual.
- Limited collateral set.
- No oracle aggregation fallback.
- Liquidation incentives are static.

## 14) Future improvements
- Add governance and configurable risk parameters.
- Add multi-oracle and circuit breakers.
- Improve liquidation auctions.
- Add formal verification and differential testing.

## Threat model and security considerations
This code explicitly addresses:
- Reentrancy (nonReentrant on stateful flows)
- Access control (owner-restricted mint/burn)
- Stale oracle data (timeout checks)
- Decimal and precision conversions (fixed-precision constants)
- Liquidation accounting and health-factor checks
- Unsafe ERC20 interaction handling (transfer result checks)
- External call failure handling (custom errors)
- Checks-effects-interactions ordering

Remaining risks for educational deployments include oracle manipulation, sudden liquidity shocks, DOS around expensive liquidations, flash-loan-driven volatility, and temporary insolvency under extreme market moves.
