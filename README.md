# Cross-Chain Token Recovery Registry 💰

> ⚠️ **Time Sensitive**: Recovery is only possible if the target nonce hasn't been used on the destination chain yet.

## Overview

This repository helps recover funds that were mistakenly sent to token contract addresses on wrong blockchains. While these funds might appear permanently lost, they can be recovered due to how Ethereum Virtual Machine (EVM) derives contract addresses through the CREATE opcode.

### Why This Matters

When a contract is deployed, its address is deterministically generated from:

1. The deployer's address
2. The deployment nonce

This means funds sent to a contract address on Chain A can be recovered on Chain B by deploying a recovery contract at the same nonce.

### Example Scenario

- Original: Token deployed on Ethereum at [nonce 46](https://etherscan.io/tx/0x0885b9e5184f497595e1ae2652d63dbdb2785de2e498af837d672f5765f28430)
- Problem: User sends [82 ETH](https://arbiscan.io/tx/0x811cf7ac6f6c10d443fdcb40bc08a8f161274bf3b6d3b03a2be94bcb43706992) to same address on Arbitrum
- Solution: Deploy recovery contract on Arbitrum using nonce 46
- Result: Funds become accessible through the recovery contract

> 🚫 **Note**: Funds on ZkSync are unrecoverable due to different contract address derivation.

## Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- Private key with enough native tokens for deployment (not need simulation)

### Installation

```shell
# Clone repository
git clone https://github.com/codeislight1/FundsRecoveryInitiative
cd FundsRecoveryInitiative

# Install dependencies
forge install
```

### Configuration

#### 1. Supported Networks

The following networks are supported via configuration in `foundry.toml`:

```toml
[rpc_endpoints]
arb = "https://arbitrum.drpc.org"
avax = "https://avalanche.drpc.org"
base = "https://mainnet.base.org"
bsc = "https://bsc-dataseed1.defibit.io"
gnosis = "https://rpc.gnosischain.com"
eth = "https://rpc.mevblocker.io"
op = "https://op-pokt.nodies.app"
polygon = "https://rpc.ankr.com/polygon"
```

#### 2. Recovery Settings

Update settings in `./script/constants.sol`:

```solidity
string constant ORIGINAL_CHAIN = "bsc";     // Chain where contract was originally deployed
string constant TARGETED_CHAIN = "eth";       // Chain where funds are stuck
uint256 constant TARGETED_NONCE = 4;         // Original deployment nonce
address constant TARGETED_CONTRACT = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
address constant broadcaster = 0xF07C30E4CD6cFff525791B4b601bD345bded7f47; // deployer address
```

## Usage

### Atomic Recovery

1. Update token list in `./script/Deploy.s.sol`:

```solidity
address[] updatedTokens = [
    // ...
];
```

2. Run recovery script:

> [!WARNING]
> only append "--broadcast --private-key YOUR_PRIVATE_KEY" to the command when executing the recovery

```shell
# Dry run (simulation)
forge script DeployRecovery

# Actual recovery (requires private key)
forge script DeployRecovery --broadcast --private-key YOUR_PRIVATE_KEY
```

Example output:

```shell
  > Deployed Recovery: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
  > Recovered Native: 16.609236676877602183 ETH
  > Recovered ERC20 tokens:
   > 4078088.277373556602614074 BUSD
   > 21632.957664 USD Coin
   > 13201.946536 Tether USD
   > 20094.329000000000000000 DAO Maker
   > 1106.791111111110000000 Immutable X
```

- You may explore "DeployRecovery" and "NativeRecovery" and "ERC20Recovery" according to your needs.

## Funds List

### 1. List By Asset Name

| Name                           | Entity             | Amount (k$) | Chain     | Address                                                                                                 |
| ------------------------------ | ------------------ | ----------- | --------- | ------------------------------------------------------------------------------------------------------- |
| Binance BUSD                   | Binance            | 4150        | BSC       | https://bscscan.com/address/0xe9e7cea3dedca5984780bafc599bd69add087d56#multichain-portfolio             |
| Binance BSC-USD                | Binance            | 628         | BSC       | https://bscscan.com/address/0x55d398326f99059ff775485246999027b3197955#multichain-portfolio             |
| Binance USDC                   | Binance            | 609         | BSC       | https://bscscan.com/address/0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d#multichain-portfolio             |
| Binance ETH                    | Binance            | 562         | BSC       | https://bscscan.com/address/0x2170ed0880ac9a755fd29b2688956bd959f933f8#multichain-portfolio             |
| BNB                            | Binance            | 316         | Ethereum  | https://etherscan.io/address/0xB8c77482e45F1F44dE1745F52C74426C631bDD52#multichain-portfolio            |
| BUSD                           | Binance            | 244         | Ethereum  | https://etherscan.io/address/0x4Fabb145d64652a948d72533023f6E7A623C7C53#multichain-portfolio            |
| Binance BTCB                   | Binance            | 52          | BSC       | https://bscscan.com/address/0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c#multichain-portfolio             |
| WBNB                           | Binance            | 48.3        | BSC       | https://bscscan.com/address/0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c#multichain-portfolio             |
| Binance SHIB                   | Binance            | 38          | BSC       | https://bscscan.com/address/0x2859e4544c4bb03966803b044a93563bd2d0dd4d#multichain-portfolio             |
| Binance DOGE                   | Binance            | 22.3        | BSC       | https://bscscan.com/address/0xba2ae424d960c26247dd6c32edc70b295c744c43#multichain-portfolio             |
| Binance XRP                    | Binance            | 18.8        | BSC       | https://bscscan.com/address/0x1d2f0da169ceb9fc7b3144628db156f3f6c60dbe#multichain-portfolio             |
| Binance ADA                    | Binance            | 14.3        | BSC       | https://bscscan.com/address/0x3ee2200efb3400fabb9aacf31297cbdd1d435d47#multichain-portfolio             |
| BUSD                           | Binance            | 11.5        | Avalanche | https://snowscan.xyz/address/0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39#multichain-portfolio            |
| Binance DAI                    | Binance            | 11          | BSC       | https://bscscan.com/address/0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3#multichain-portfolio             |
| Binance LINK                   | Binance            | 8.2         | BSC       | https://bscscan.com/address/0xf8a0bf9cf54bb92f17374d9e9a321e6a111a51bd#multichain-portfolio             |
| Binance DOT                    | Binance            | 7           | BSC       | https://bscscan.com/address/0x7083609fce4d1d8dc0c979aab8c869ea2c873402#multichain-portfolio             |
| Binance BCH                    | Binance            | 4           | BSC       | https://bscscan.com/address/0x8ff795a6f4d97e7887c79bea79aba5cc76444adf#multichain-portfolio             |
| Binance SNX                    | Binance            | 4           | BSC       | https://bscscan.com/address/0x9ac983826058b8a9c7aa1c9171441191232e8404#multichain-portfolio             |
| USDT                           | Tether             | 811         | Ethereum  | https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7#multichain-portfolio            |
| USDT                           | Tether             | 31          | Avalanche | https://snowscan.xyz/address/0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7#multichain-portfolio            |
| USDT.e                         | Avalanche          | 674         | Avalanche | https://snowscan.xyz/address/0xc7198437980c041c805a1edcba50c1ce5db95118#multichain-portfolio            |
| USDC.e                         | Avalanche          | 29          | Avalanche | https://snowscan.xyz/address/0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664#multichain-portfolio            |
| WETH.e                         | Avalanche          | 22.6        | Avalanche | https://snowscan.xyz/address/0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab#multichain-portfolio            |
| DAI.e                          | Avalanche          | 15          | Avalanche | https://snowscan.xyz/address/0xd586e7f844cea2f87f50152665bcbc2c279d8d70#multichain-portfolio            |
| USDT-Pos                       | Polygon            | 97          | Polygon   | https://polygonscan.com/address/0xc2132d05d31c914a87c6611c10748aeb04b58e8f#multichain-portfolio         |
| OM                             | Polygon            | 85.2        | Polygon   | https://polygonscan.com/address/0xc3ec80343d2bae2f8e680fdadde7c17e71e114ea#multichain-portfolio         |
| USDC-Pos                       | Polygon            | 75.3        | Polygon   | https://polygonscan.com/address/0x2791bca1f2de4661ed88a30c99a7a9449aa84174#multichain-portfolio         |
| MATIC                          | Polygon            | 70.5        | Ethereum  | https://etherscan.io/address/0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0#multichain-portfolio            |
| WETH                           | Polygon            | 71.5        | Polygon   | https://polygonscan.com/address/0x7ceb23fd6bc0add59e62ac25578270cff1b9f619                              |
| DAI-Pos                        | Polygon            | 29.8        | Polygon   | https://polygonscan.com/address/0x8f3cf7ad23cd3cadbd9735aff958023239c6a063#multichain-portfolio         |
| MATIC                          | Polygon            | 9.2         | BSC       | https://bscscan.com/address/0xcc42724c6683b7e57334c4e856f4c9965ed682bd#multichain-portfolio             |
| Base Portal                    | Base               | 348         | Ethereum  | https://etherscan.io/address/0x49048044d57e1c92a77f79988d21fa8faf74e97e#multichain-portfolio            |
| Base Bridge                    | Base               | 26          | Ethereum  | https://etherscan.io/address/0x3154cf16ccdb4c6d922629664174b904d80f2c35#multichain-portfolio            |
| USDbC                          | Base               | 6.1         | Base      | https://etherscan.io/address/0xd9aaec86b65d86f6a7b5b1b0c42ffa531710b6ca#multichain-portfolio            |
| WETH                           | MakerDAO           | 273         | Ethereum  | https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#multichain-portfolio            |
| DAI                            | MakerDAO           | 57.6        | Ethereum  | https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#multichain-portfolio            |
| IMX                            | Immutable X        | 303         | Ethereum  | https://etherscan.io/address/0xf57e7e7c23978c3caec3c3548e3d615c346e79ff#multichain-portfolio            |
| USDC                           | Circle             | 191         | Ethereum  | https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48#multichain-portfolio            |
| USDC                           | Circle             | 36.6        | Avalanche | https://snowscan.xyz/address/0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e#multichain-portfolio            |
| USDC                           | Circle             | 28.5        | Arbitrum  | https://arbiscan.io/address/0xaf88d065e77c8cc2239327c5edb3a432268e5831#multichain-portfolio             |
| USDC                           | Circle             | 21.2        | Base      | https://etherscan.io/address/0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913#multichain-portfolio            |
| USDC                           | Circle             | 15.1        | Optimism  | https://optimistic.etherscan.io/address/0x0b2c639c533813f4aa9d7837caf62653d097ff85#multichain-portfolio |
| CRYPTOPUNKS (Ͼ)                | Yuga Labs          | 244         | Ethereum  | https://etherscan.io/address/0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB#multichain-portfolio            |
| SHIB                           | Shiba Inu          | 142         | Ethereum  | https://etherscan.io/address/0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE#multichain-portfolio            |
| Radiant                        | Radiant            | 132         | Arbitrum  | https://arbiscan.io/address/0x3082cc23568ea640225c2467653db90e9250aaa0#multichain-portfolio             |
| ORN                            | Orion Protocol     | 150         | Ethereum  | https://etherscan.io/address/0x0258f474786ddfd37abce6df6bbb1dd5dfc4434a#multichain-portfolio            |
| Blast Portal                   | Blast              | 51          | Ethereum  | https://etherscan.io/address/0x0Ec68c5B10F21EFFb74f2A5C61DFe6b08C0Db6Cb#multichain-portfolio            |
| Blast L1 Bridge Proxy          | Blast              | 40          | Ethereum  | https://etherscan.io/address/0x3a05E5d33d7Ab3864D53aaEc93c8301C1Fa49115#multichain-portfolio            |
| Blast L1 Standard Bridge Proxy | Blast              | 20          | Ethereum  | https://etherscan.io/address/0x697402166Fbf2F22E970df8a6486Ef171dbfc524#multichain-portfolio            |
| Blur.io: Marketplace 3         | Blur               | 40.8        | Ethereum  | https://etherscan.io/address/0xb2ecfe4e4d61f8790bbb9de2d1259b9e2410cea5#multichain-portfolio            |
| Blur Bidding                   | Blur               | 32.8        | Ethereum  | https://etherscan.io/address/0x0000000000a39bb272e79075ade125fd351887ac#multichain-portfolio            |
| Blur Blend                     | Blur               | 20.1        | Ethereum  | https://etherscan.io/address/0x29469395eaf6f95920e59f858042f0e28d98a20b#multichain-portfolio            |
| Blur.io: Marketplace           | Blur               | 8.8         | Ethereum  | https://etherscan.io/address/0x000000000000ad05ccc4f10045630fb830b95127#multichain-portfolio            |
| bridged USDC.e                 | Arbitrum           | 55          | Arbitrum  | https://arbiscan.io/address/0xff970a61a04b1ca14834a43f5de4533ebddb5cc8#multichain-portfolio             |
| ARB                            | Arbitrum           | 24          | Arbitrum  | https://arbiscan.io/address/0x912ce59144191c1204e64559fe8253a0e49e6548#multichain-portfolio             |
| Arbitrum: Delayed Inbox        | Arbitrum           | 13.3        | Ethereum  | https://etherscan.io/address/0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f#multichain-portfolio            |
| ARB                            | Arbitrum           | 9.4         | Ethereum  | https://etherscan.io/address/0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1#multichain-portfolio            |
| QNT                            | Quant              | 91.7        | Ethereum  | https://etherscan.io/address/0x4a220e6096b25eadb88358cb44068a3248254675#multichain-portfolio            |
| REPv2                          | Reputation         | 92.2        | Ethereum  | https://etherscan.io/address/0x221657776846890989a759ba2973e427dff5c9bb#multichain-portfolio            |
| FTM                            | Fantom             | 87          | Ethereum  | https://etherscan.io/address/0x4e15361fd6b4bb609fa63c81a2be19d873717870#multichain-portfolio            |
| SYN                            | Synapse            | 77          | Ethereum  | https://etherscan.io/address/0x0f2d719407fdbeff09d87557abb7232601fd9f29#multichain-portfolio            |
| SSV                            | SSV                | 66.7        | Ethereum  | https://etherscan.io/address/0x9d65ff81a3c488d585bbfb0bfe3c7707c7917f54#multichain-portfolio            |
| Coinbase 10                    | Coinbase           | 52          | Ethereum  | https://etherscan.io/address/0xa9d1e08c7793af67e9d92fe308d5697fb81d3e43#multichain-portfolio            |
| BEL                            | Bella Protocol     | 48.1        | BSC       | https://bscscan.com/address/0x8443f091997f06a61670b735ed92734f5628692f#multichain-portfolio             |
| Optimsim Gateway               | Optimism           | 40          | Ethereum  | https://etherscan.io/address/0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1#multichain-portfolio            |
| TIME                           | Wonderland         | 34.4        | Avalanche | https://snowscan.xyz/address/0xb54f16fb19478766a268f172c9480f8da1a7c9c3#multichain-portfolio            |
| JASMY                          | Jasmy              | 36.2        | Ethereum  | https://etherscan.io/address/0x7420B4b9a0110cdC71fB720908340C03F9Bc03EC#multichain-portfolio            |
| Gitcoin Multisig               | Gitcoin            | 33.4        | Ethereum  | https://etherscan.io/address/0xde21f729137c5af1b01d73af1dc21effa2b8a0d6#multichain-portfolio            |
| SAND                           | Sandbox            | 21.3        | Ethereum  | https://etherscan.io/address/0x3845badAde8e6dFF049820680d1F14bD3903a5d0#multichain-portfolio            |
| SAND                           | Sandbox            | 9.4         | Polygon   | https://polygonscan.com/address/0xBbba073C31bF03b8ACf7c28EF0738DeCF3695683#multichain-portfolio         |
| Wormhole Portal                | Wormhole           | 29.2        | Ethereum  | https://etherscan.io/address/0x3ee18b2214aff97000d974cf647e7c347e8fa585#multichain-portfolio            |
| dydx l2 perpetual sc           | DYDX               | 25.2        | Ethereum  | https://etherscan.io/address/0xd54f502e184b6b739d7d27a6410a67dc462d69c8#multichain-portfolio            |
| USTC                           | Terra              | 24.8        | Ethereum  | https://etherscan.io/address/0xa47c8bf37f92aBed4A126BDA807A7b7498661acD#multichain-portfolio            |
| BAKE                           | BakerySwap         | 23          | BSC       | https://bscscan.com/address/0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5#multichain-portfolio             |
| WBTC                           | Wrapped BTC        | 23.7        | Ethereum  | https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599#multichain-portfolio            |
| XAVA                           | Avalaunch          | 23.3        | Avalanche | https://snowscan.xyz/address/0xd1c3f94de7e5b45fa4edbba472491a9f4b166fc4#multichain-portfolio            |
| BRISE                          | Bitrise            | 22.1        | BSC       | https://bscscan.com/address/0x8FFf93E810a2eDaaFc326eDEE51071DA9d398E83#multichain-portfolio             |
| EGC                            | EverGrow           | 20          | BSC       | https://bscscan.com/address/0xC001BBe2B87079294C63EcE98BdD0a88D761434e#multichain-portfolio             |
| 10SET                          | 10SET              | 20          | BSC       | https://bscscan.com/address/0x1ae369a6ab222aff166325b7b87eb9af06c86e57#multichain-portfolio             |
| ether.fi liquidity pool        | EtherFi            | 20.3        | Ethereum  | https://etherscan.io/address/0x308861a430be4cce5502d0a12724771fc6daf216#multichain-portfolio            |
| Kyberswap Router V2            | KyberSwap          | 20.6        | Ethereum  | https://etherscan.io/address/0x6131b5fae19ea4f9d964eac0408e4408b66337b5#multichain-portfolio            |
| THORCHAIN                      | ThorChain          | 17.7        | Ethereum  | https://etherscan.io/address/0xd37bbe5744d730a1d98d8dc97c42f0ca46ad7146#multichain-portfolio            |
| LI FI diamond                  | LiFi               | 13.4        | Ethereum  | https://etherscan.io/address/0x1231deb6f5749ef6ce6943a275a1d3e7486f4eae#multichain-portfolio            |
| JOE                            | Joe Trader         | 11.3        | Avalanche | https://snowscan.xyz/address/0x6e84a6216ea6dacc71ee8e6b0a5b7322eebc0fdd#multichain-portfolio            |
| L1 Scroll Messenger Proxy      | Scroll             | 11.8        | Ethereum  | https://etherscan.io/address/0x6774Bcbd5ceCeF1336b5300fb5186a12DDD8b367#multichain-portfolio            |
| INJ                            | Injective Protocol | 11.7        | Ethereum  | https://etherscan.io/address/0xe28b3B32B6c345A34Ff64674606124Dd5Aceca30#multichain-portfolio            |
| USDP                           | Paxos              | 12.5        | Ethereum  | https://etherscan.io/address/0x8e870d67f660d95d5be530380d0ec0bd388289e1#multichain-portfolio            |
| MX                             | MEXC               | 13          | Ethereum  | https://etherscan.io/address/0x11eef04c884e24d9b7b4760e7476d06ddf797f36#multichain-portfolio            |
| RNDR                           | Cerol              | 13          | Polygon   | https://polygonscan.com/address/0x61299774020da444af134c82fa83e3810b309991#multichain-portfolio         |
| DEGEN                          | Degen              | 7.9         | Base      | https://etherscan.io/address/0x4ed4e862860bed51a9570b96d89af5e1b0efefed#multichain-portfolio            |
| FRAX                           | Frax Finance       | 9.9         | Arbitrum  | https://arbiscan.io/address/0x17fc002b466eec40dae837fc4be5c67993ddbd6f#multichain-portfolio             |
| stETH                          | Lido               | 8.1         | Ethereum  | https://etherscan.io/address/0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84#multichain-portfolio            |
| ENS: Cold wallet               | ENS                | 8.7         | Ethereum  | https://etherscan.io/address/0x690f0581ececcf8389c223170778cd9d029606f2#multichain-portfolio            |
| PEOPLE                         | ConstitutionDAO    | 6.6         | Ethereum  | https://etherscan.io/address/0x7a58c0be72be218b41c608b7fe7c5bb630736c71#multichain-portfolio            |
| Opensea Wyvern V2              | OpenSea            | 6.7         | Ethereum  | https://etherscan.io/address/0x7f268357a8c2552623316e2562d90e642bb538e5#multichain-portfolio            |
| LINK                           | Chainlink          | 6.7         | Ethereum  | https://etherscan.io/address/0x514910771af9ca656af840dff83e8264ecf986ca#multichain-portfolio            |
| **Total**                      |                    | **12159.4** |           |                                                                                                         |

### 2. List By Entity

| Entity             | Amount (k$) |
| ------------------ | ----------- |
| Binance            | 6748.4      |
| Tether             | 842         |
| Avalanche          | 740.6       |
| Polygon            | 438.5       |
| Base               | 380.1       |
| MakerDAO           | 330.6       |
| Immutable X        | 303         |
| Circle             | 292.4       |
| Yuga Labs          | 244         |
| Shiba Inu          | 142         |
| Radiant            | 132         |
| Orion Protocol     | 150         |
| Blast              | 111         |
| Blur               | 102.5       |
| Arbitrum           | 101.7       |
| Quant              | 91.7        |
| Reputation         | 92.2        |
| Fantom             | 87          |
| Synapse            | 77          |
| SSV                | 66.7        |
| Coinbase           | 52          |
| Bella Protocol     | 48.1        |
| Optimism           | 40          |
| Wonderland         | 34.4        |
| Jasmy              | 36.2        |
| Gitcoin            | 33.4        |
| Sandbox            | 30.7        |
| Wormhole           | 29.2        |
| DYDX               | 25.2        |
| Terra              | 24.8        |
| BakerySwap         | 23          |
| Wrapped BTC        | 23.7        |
| Avalaunch          | 23.3        |
| Bitrise            | 22.1        |
| EverGrow           | 20          |
| 10SET              | 20          |
| EtherFi            | 20.3        |
| KyberSwap          | 20.6        |
| ThorChain          | 17.7        |
| LiFi               | 13.4        |
| Joe Trader         | 11.3        |
| Scroll             | 11.8        |
| Injective Protocol | 11.7        |
| Paxos              | 12.5        |
| MEXC               | 13          |
| Cerol              | 13          |
| Degen              | 7.9         |
| Frax Finance       | 9.9         |
| Lido               | 8.1         |
| ENS                | 8.7         |
| ConstitutionDAO    | 6.6         |
| OpenSea            | 6.7         |
| Chainlink          | 6.7         |
| **Total**          | **12159.4** |
