// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TxSimulatorRegistry
 * @dev Stores user profiles, preferences, and simulation reports onchain.
 */
contract TxSimulatorRegistry {
    struct UserProfile {
        string displayName;
        string preferencesJSON; // Stores UI theme, default gas settings, etc.
        uint256 createdAt;
    }

    struct SimulationRecord {
        address contractTarget;
        bytes4 functionSelector;
        string simulationReportURI; // IPFS or compact JSON reference
        uint256 estimatedGas;
        uint256 timestamp;
    }

    mapping(address => UserProfile) public profiles;
    mapping(address => SimulationRecord[]) public userSimulations;

    event ProfileUpdated(address indexed user, string displayName);
    event SimulationSaved(address indexed user, address indexed target, bytes4 selector);

    function updateProfile(string calldata _displayName, string calldata _preferencesJSON) external {
        if (profiles[msg.sender].createdAt == 0) {
            profiles[msg.sender].createdAt = block.timestamp;
        }
        profiles[msg.sender].displayName = _displayName;
        profiles[msg.sender].preferencesJSON = _preferencesJSON;
        emit ProfileUpdated(msg.sender, _displayName);
    }

    function saveSimulation(
        address _target,
        bytes4 _selector,
        string calldata _reportURI,
        uint256 _estimatedGas
    ) external {
        userSimulations[msg.sender].push(SimulationRecord({
            contractTarget: _target,
            functionSelector: _selector,
            simulationReportURI: _reportURI,
            estimatedGas: _estimatedGas,
            timestamp: block.timestamp
        }));
        emit SimulationSaved(msg.sender, _target, _selector);
    }

    function getUserSimulations(address _user) external view returns (SimulationRecord[] memory) {
        return userSimulations[_user];
    }
}