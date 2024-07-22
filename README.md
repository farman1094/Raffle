## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Deployement
Contract address: 0x20A5d09658f9758fb31B74Ad281CD50631428270 (Sepolia)
## Working
1. Raffle, people can participate by paying entry fees
2. After a period of time, result will be declared
   1. Using Chainlink VRF --> Randomness which help to choose the winner
   2. Using Chainlink automation --> Result will declare automatically after the time has passed
3. All money would transfer to winner

## Testing
1. Write deploy scripts
   1. these will not work on zkSync
2. Write tests
   1. local chain
   2. Forked testnet
   3. Forked mainnet

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
