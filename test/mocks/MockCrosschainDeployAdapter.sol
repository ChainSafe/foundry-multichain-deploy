// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20;

contract MockCrosschainDeployAdapter {
    /**
     * @notice Deposits to the Bridge contract using the PermissionlessGenericHandler,
     *     @notice to request contract deployments on other chains.
     *     @param deployBytecode Contract deploy bytecode.
     *     @param gasLimit Contract deploy and init gas.
     *     @param salt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @param constructorArgs Bytes to add to the deployBytecode, or empty, one per chain.
     *     @param initDatas Bytes to send to the contract after deployment, or empty, one per chain.
     *     @param destinationDomainIDs Sygma Domain IDs of target chains.
     *     @param fees Native currency amount to pay for Sygma services, one per chain. Empty for current domain.
     */
    function deploy(
        bytes calldata deployBytecode,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas,
        uint8[] memory destinationDomainIDs,
        uint256[] memory fees
    ) external payable {
        // TODO: Fill this with something that mocks it.
    }

    /**
     * @notice Computes the address where the contract will be deployed on specified chain.
     *     @param sender Address that requested deploy.
     *     @param salt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @param chainId The ID of the chain, as shown on https://chainlist.org
     *     @return Address where the contract will be deployed on specified chain.
     */
    function computeContractAddressForChain(address sender, bytes32 salt, bool isUniquePerChain, uint256 chainId)
        external
        view
        returns (address)
    {
        address newAddress;
        return newAddress;
    }

    /**
     * @notice Returns total amount of native currency needed for a deploy request.
     *     @param deployBytecode Contract deploy bytecode.
     *     @param gasLimit Contract deploy and init gas.
     *     @param salt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @param constructorArgs Bytes to add to the deployBytecode, or empty, one per chain.
     *     @param initDatas Bytes to send to the contract after deployment, or empty, one per chain.
     *     @param destinationDomainIDs Sygma Domain IDs of target chains.
     */
    function calculateDeployFee(
        bytes calldata deployBytecode,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas,
        uint8[] memory destinationDomainIDs
    ) external view returns (uint256[] memory fees) {
        uint256[] memory fees = new uint256[](4);
        return fees;
    }
}
