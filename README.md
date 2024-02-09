# foundry-multichain-deploy (powered by Sygma)

> **Warning**
>
> Only testnet multichain deployment is available. Mainnet deployment will be enabled soon!

Provides `foundry` tooling for deploying contracts on multiple chains in a single ttransaction
and providing identical address on each chain.
See
[ChainSafe/hardhat-plugin-multichain-deploy]("https://github.com/ChainSafe/hardhat-plugin-multichain-deploy")
for the Hardhat plugin version.

[Sygma protocol](https://buildwithsygma.com/)

## Installation

Run `forge install chainsafe/foundry-multichain-deploy` to install this plugin to your foundry project.

## Usage

The `CrosschainDeployScript` contract is a foundry "script", which means that it
is not deployed onto the blockchain. It provides a few helper methods
that make it easier to deal with the `CrosschainDeployAdapter` from the hardhat
repository.

To use it, first import the `CrosschainDeployScript` and inherit from it.

```solidity
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CrosschainDeployScript} from "foundry-multichain-deploy/CrosschainDeployScript.sol";

contract CounterScript is CrosschainDeployScript {

    function run() public {
        string memory artifact = "Counter.sol:Counter";
        this.setContract(artifact);
        bytes memory constructorArgs = abi.encode(uint256(10));
        bytes memory initData = abi.encodeWithSignature("setNumber(uint256)", uint256(10));
        this.addDeploymentTarget("sepolia", constructorArgs, initData);
        this.addDeploymentTarget("holesky", constructorArgs, initData);
                //this is gas limit on destimation networks
        //there is no way to estimate gas cost of deploying contract inside script
        //you can use `forge inspect Counter gasEstimates` to get contract creation but add at least 100k buffer for bridge execution
        uint256 destinationGasLimit = 200000;
        uint256[] memory fees = this.getFees(destinationGasLimit, false);
        uint256 totalFee = this.getTotalFee(destinationGasLimit, false);
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address[] memory contractAddresses = this.deploy{value: totalFee}(deployerPrivateKey, fees, destinationGasLimit, false);
        console.log("Sepolia contract address %s", contractAddresses[0]);
        console.log("Holesky contract address %s", contractAddresses[1]);
    }
}

```

Now, you can run this with `forge script script/SampleDeployScript.sol:SampleDeployScript --rpc-url $CHAIN_RPC_URL --broadcast`.

This script is not deployed, but it instead constructs the calls to the upstream
contract and broadcasts them (thanks to the `--broadcast` flag).

> **Warning**
>
> Source code verification doesn't work out of the box. You can run verification in [separate command](https://book.getfoundry.sh/forge/deploying#verifying-a-pre-existing-contract)


### Encoding Arguments

The `constructorArgs` and `initData` arguments use the encoded format for the
values that get passed to the adapter for deployment. Notice how in the example
above, these are encoded using `encode` and `encodeWithSignature`.

The `Counter` example has a constructor that takes a `uint256` value. So
it requires a value to be passed as `constructorArgs`.  We use `bytes memory
constructorArgs = abi.encode(uint256(10));` to do so.

If a contract constructor doesn't have any input arguments, you can just use
`bytes memory constructorArgs = '';` for that particular constructor.

Now, the `setNumber` function of the `Counter` takes a `uint256` argument as
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