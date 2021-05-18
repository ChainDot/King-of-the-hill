// SPDX-License-Identifier: MIT

// testnet Rinkeby
//0xA95024550d9cf033D862a8A3Db5e3285ac996893

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

/// @author Henri NAY
/// @title King of the Hill
/// @notice  Online Betting game
contract KOTH {
    using Address for address payable;

    address private _owner;
    address private _king;
    uint256 private _timer;
    uint256 private _prize;

    event refundedSurplus(address indexed sender, uint256 refund);
    event paidFees(address indexed owner_, uint256 fees);
    event paidKing(address indexed king_, uint256 winner);

    constructor(address owner_) payable {
        require(
            msg.value >= 1**15,
            "KOTH: Don't be so cheap at least 1 finney"
        );
        _owner = owner_;
        _king = owner_;
        _timer = block.number + 5;
        _prize = msg.value;
    }

    modifier ExceptOwner() {
        require(
            msg.sender != _owner,
            "KOTH: You are the owner, you are not allowed to play!"
        );
        _;
    }

    modifier toBeKing() {
        require(
            msg.value >= (_prize * 2),
            "KOTH: Bet size to small, try again"
        );
        require(msg.value > 0, "KOTH: You cannot send 0 ETH");
        _;
    }

    receive() external payable toBeKing ExceptOwner {
        require(msg.sender != _king, "KOTH: You are the king of the hill");

        ///@notice start new round
        if (block.number >= _timer) {
            uint256 fees = (_prize * 10) / 100;
            uint256 winner = (_prize * 80) / 100;
            _prize -= (winner + fees);
            payable(_owner).sendValue(fees);
            payable(_king).sendValue(winner);
            emit paidFees(_owner, fees);
            emit paidKing(_king, fees);
        }

        uint256 refund = msg.value - (_prize * 2);
        ///@ notice refund the difference between bet and expected msg.value
        if (refund != 0) {
            _prize -= refund;
            payable(msg.sender).sendValue(refund);
            emit refundedSurplus(msg.sender, refund);
        }

        _timer = block.number;
        _king = msg.sender;
        _prize += msg.value;
    }

    function pot() external payable toBeKing ExceptOwner {
        require(msg.sender != _king, "KOTH: You are the king of the hill");

        ///@notice start new round
        if (block.number >= _timer) {
            uint256 fees = (_prize * 10) / 100;
            uint256 winner = (_prize * 80) / 100;
            _prize -= (winner + fees);
            payable(_owner).sendValue(fees);
            payable(_king).sendValue(winner);
            emit paidFees(_owner, fees);
            emit paidKing(_king, fees);
        }

        uint256 refund = msg.value - (_prize * 2);
        ///@ notice refund the difference between bet and expected msg.value
        if (refund != 0) {
            _prize -= refund;
            payable(msg.sender).sendValue(refund);
            emit refundedSurplus(msg.sender, refund);
        }

        _timer = block.number;
        _king = msg.sender;
        _prize += msg.value;
    }

    // @dev getters

    function king() public view returns (address) {
        return _king;
    }

    function blockStart() public view returns (uint256) {
        return _timer;
    }

    function blockNumber() public view returns (uint256) {
        return block.number;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function prize() public view returns (uint256) {
        return _prize;
    }
}
