// SPDX-License-Identifier: UNLICENSED
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
        // this is the gas limit on destination networks
        // there is no way to estimate gas cost of deploying contract inside script
        // you can use `forge inspect Counter gasEstimates` to get contract
        // creation but add at least 100k buffer for bridge execution
        uint256 destinationGasLimit = 500000;
        uint256[] memory fees = this.getFees(destinationGasLimit, false);
        uint256 totalFee = this.getTotalFee(destinationGasLimit, false);
        // NOTE: Make sure you set the PRIVATE_KEY envvar.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address[] memory contractAddresses =
            this.deploy{value: totalFee}(deployerPrivateKey, fees, destinationGasLimit, false);
        console.log("Sepolia contract address %s", contractAddresses[0]);
        console.log("Holesky contract address %s", contractAddresses[1]);
    }
}
