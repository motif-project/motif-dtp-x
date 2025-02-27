# motif-dtp-x

motif-dtp-x is an experimental sandbox for exploring and prototyping Delegated Traded Positions (DTP) issuance designs for the Motif protocol. This repository serves as a space to conceptualize, test, and iterate on innovative mechanisms for creating and managing DTPs, leveraging Bitcoin-backed security through Bitcoin Pods and the EigenLayer AVS architecture.

## 🚀 Overview

Motif’s DTPs allow BTC liquidity providers to create tradable tokens representing reward-bearing strategies secured by Bitcoin Pods. The motif-dtp-x repo focuses on:
	-	Designing and testing DTP issuance models
	-	Prototyping interactions between DTPs, Bitcoin Pods, and AVS
	-	Evaluating collateral management and token minting processes

## ⚙️ Getting Started

To clone the repository:
````
git clone https://github.com/usmanshahid86/motif-dtp-x.git
cd motif-dtp-x
````

## Install Dependencies

Ensure you have Foundry installed. Follow the [Foundry installation guide](), then run:

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
