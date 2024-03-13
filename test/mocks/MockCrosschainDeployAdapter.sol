// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20;

contract MockCrosschainDeployAdapter {
    /**
     * @notice Deposits to the Bridge contract using the PermissionlessGenericHandler,
     *     @notice to request contract deployments on other chains.
     */
    function deploy(
        bytes calldata,
        uint256,
        bytes32,
        bool,
        bytes[] memory,
        bytes[] memory,
        uint8[] memory,
        uint256[] memory
    ) external payable {
        // TODO: Fill this with something that mocks it.
    }

    /**
     * @notice Computes the address where the contract will be deployed on specified chain.
     *     @return Address where the contract will be deployed on specified chain.
     */
    function computeContractAddressForChain(address, bytes32, bool, uint256) external pure returns (address) {
        address newAddress;
        return newAddress;
    }

    /**
     * @notice Returns total amount of native currency needed for a deploy request.
     */
    function calculateDeployFee(bytes calldata, uint256, bytes32, bool, bytes[] memory, bytes[] memory, uint8[] memory)
        external
        pure
        returns (uint256[] memory fees)
    {
        fees = new uint256[](4);
        return fees;
    }
}
