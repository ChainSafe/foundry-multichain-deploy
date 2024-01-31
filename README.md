# foundry-multichain-deploy

Provides `foundry` tooling for the multichain deployment contract built atop of Sygma. See [ChainSafe/hardhat-plugin-multichain-deploy]("https://github.com/ChainSafe/hardhat-plugin-multichain-deploy") for more details.

## Usage

The `CrosschainDeployScript` contract is a foundry "script", which means that it is not really deployed onto the blockchain. It provides a few helper methods that make it easier to deal with the `CrosschainDeployAdapter` from the hardhat repository.

To use it, first import the `CrosschainDeployScript`.

```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20

contract SampleContract {
    function deployMultichain public payable() {
        // Remember that forge "builds" the contracts and stores them and their ABI in the root level of `out` so you'd just need to use the contract file name and the contract name and forge gets it from the ABI.
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript("SimpleContract.sol:SimpleContract");
        bytes memory constructorArgs = "0x";
        bytes memory initData = "0x";
        crosschainDeployScript.setCrosschainDeployContractAddress(crosschainDeployAdapterAddress);
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        crosschainDeployScript.deploy{value: msg.value}(50000, false);
    }
}
```

A good example of how to use this project is demonstrated in the [`test/unit/CrosschainDeployScript.t.sol`](test/unit/CrosschainDeployScriptTest.t.sol) file.


## Development

[Install foundry](https://book.getfoundry.sh/getting-started/installation) and [`just`](https://github.com/casey/just).

Check the `justfile` for more instructions on how to run this project. Run `just --list` to see all the options.

Note that all integration tests *should* have `Integration` in the test function name for them to work, unless you'd like to use `--match-test` specifically for those tests. However, to keep things simple, it's best to follow this practice.