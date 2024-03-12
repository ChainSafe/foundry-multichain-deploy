# Development

## Dependencies

* [foundry](https://book.getfoundry.sh/getting-started/installation)
* [`just`](https://github.com/casey/just) (for running the recipes in the Justfile)

## Getting Started

Check the `justfile` for more instructions on how to run this project. Run `just --list` to see all the options. To start off, run `just build` to ensure that the code builds on your machine. Open issues if there's anything that appears to be broken.

## Design

The core of this plugin is the `Script` mechanism of foundry, which allows us to use `solidity` for scripting. The `CrosschainDeployScript` is a `Script`, which allows us to use certain `cheats` within its runtime so that we can emulate a running chain.

What this entails is that you can further inherit from `CrosschainDeployScript`, implement a `run` `public` method and use it to setup all the necessary background for your contract to be deployed on the Sygma networks.

The core of this is the `CrosschainDeployAdapterInterface.sol:ICrosschainDeployAdapter`, which connects to the upstream hardhat-based contract and calls the `deploy` method for the user. For testing purposes, this is mocked in the `test/mocks/MockCrosschainDeployAdapter.sol` file.

The [example](example/README.md) goes through how to use this from a user's perspective but this document will describe how the code works under the hood.

## Resources

If you're looking for resources on learning foundry and solidity, here are a few.

* [Patrick Collins' Foundry Course](https://www.youtube.com/playlist?list=PL4Rj_WH6yLgWe7TxankiqkrkVKXIwOP42)
* [Cryptozombies](https://cryptozombies.io/en/solidity)
* [Solidity By Example](https://solidity-by-example.org/first-app/)
* [Foundry Resources](https://github.com/crisgarner/awesome-foundry)