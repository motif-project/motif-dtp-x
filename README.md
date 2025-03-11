# motif-dtp-x

**motif-dtp-x** is an experimental sandbox for exploring and prototyping Delegated Traded Positions (DTP) issuance designs for the Motif protocol. This repository serves as a space to conceptualize, test, and iterate on innovative mechanisms for creating and managing DTPs, leveraging Bitcoin-backed security through Bitcoin Pods and the EigenLayer AVS architecture.

## 🚀 Overview

Motif’s DTPs allow BTC liquidity providers to create tradable tokens representing reward-bearing strategies secured by Bitcoin Pods. The motif-dtp-x repo focuses on:
	-	Designing and testing DTP issuance models
	-	Prototyping interactions between DTPs, Bitcoin Pods, and AVS
	-	Evaluating collateral management and token minting processes

## Holesky Testnet Deployment

To deploy the DTP Factory and MFT Registry on the Holesky testnet, follow these steps:

1. Clone the repository:

```bash
git clone https://github.com/usmanshahid86/motif-dtp-x.git
cd motif-dtp-x
```

2. Install dependencies:

```bash
forge install
```

3. Set your RPC URL in the `.env` file:

```bash
RPC_URL_HOLESKY_NEW=https://ethereum-holesky.publicnode.com
```

4. Deploy the DTP Factory and MFT Registry:

```bash
$ forge script script/DTPDeploy.s.sol:DTPDeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## Deployment Addresses

The DTP Factory and MFT Registry are deployed on the Holesky testnet. The addresses are:

- DTP Factory: `0x3570F094C83C54cc3104ea576553b5E70215116d`
- MFT Registry: `0xe96701fB2F56b0536525498F1901330EA961fA75`

