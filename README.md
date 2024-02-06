# foundry-multichain-deploy

Provides `foundry` tooling for the multichain deployment contract built atop of
Sygma. See
[ChainSafe/hardhat-plugin-multichain-deploy]("https://github.com/ChainSafe/hardhat-plugin-multichain-deploy")
for more details.

## Usage

The `CrosschainDeployScript` contract is a foundry "script", which means that it
is not really deployed onto the blockchain. It provides a few helper methods
that make it easier to deal with the `CrosschainDeployAdapter` from the hardhat
repository.

To use it, first import the `CrosschainDeployScript`.

```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20

contract SampleContract {
    function deployMultichain public payable() {
        // Remember that forge "builds" the contracts and stores them and their ABI in the root level of `out` so you'd just need to use the contract file name and the contract name and forge gets it from the ABI.
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript("SimpleContract.sol:SimpleContract");
        bytes memory constructorArgs = abi.encode(uint256("10"));
        bytes memory initData = abi.encode("add(uint256)", uint256(10));
        crosschainDeployScript.setCrosschainDeployContractAddress(crosschainDeployAdapterAddress);
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        crosschainDeployScript.deploy{value: msg.value}(50000, false);
    }
}
```

A good example of how to use this project is demonstrated in the
[`test/unit/CrosschainDeployScript.t.sol`](test/unit/CrosschainDeployScriptTest.t.sol)
file.

### Encoding Arguments

The `constructorArgs` and `initData` arguments use the encoded format for the
values that get passed to the adapter for deployment. Notice how in the example
above, these are encoded using `encode` and `encodePacked`.

The `SimpleContract` example has a constructor that takes a `uint256` value. So
it requires a value to be passed as `constructorArgs`.  We use `bytes memory
constructorArgs = abi.encode(uint256(10));` to do so.

If a contract constructor doesn't have any input arguments, you can just use
`bytes memory constructorArgs = '';` for that particular constructor.

Now, the `add` function of the `SimpleContract` takes a `uint256` argument as
well, but to pass this to `initDatas`, you need to pass the function signature
as well. So you'd have to use `bytes memory initData =
abi.encodeWithSignature("add(uint256)", uint256(10));`. If you're calling a
function like `inc()` which takes no arguments, just say `bytes memory initData
= abi.encodeWithSignature("inc()");` instead.

To learn more, check out the ways you can use `abi.encode` and
`abi.encodeWithSignature` in the foundry book.


## Development

[Install foundry](https://book.getfoundry.sh/getting-started/installation) and [`just`](https://github.com/casey/just).

Check the `justfile` for more instructions on how to run this project. Run `just --list` to see all the options.

Note that all integration tests *should* have `Integration` in the test function name for them to work, unless you'd like to use `--match-test` specifically for those tests. However, to keep things simple, it's best to follow this practice.