 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedWasteManagement is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public celoToken;

    struct Waste {
        uint256 id;
        uint256 amount;
        address producer;
        address transporter;
        address recycler;
        bool isCollected;
        bool isTransported;
        bool isRecycled;
    }

    uint256 private wasteCounter;
    mapping(uint256 => Waste) public wastes;

    uint256 public wasteCollectionFee;
    uint256 public wasteTransportationFee;
    uint256 public wasteRecyclingFee;

    event WasteCollected(uint256 indexed wasteId, address indexed wasteProducer, uint256 amount);
    event WasteTransported(uint256 indexed wasteId, address indexed transporter, uint256 amount);
    event WasteRecycled(uint256 indexed wasteId, address indexed recycler, uint256 amount);

    constructor(
        address _celoTokenAddress,
        uint256 _wasteCollectionFee,
        uint256 _wasteTransportationFee,
        uint256 _wasteRecyclingFee
    ) {
        celoToken = IERC20(_celoTokenAddress);
        wasteCollectionFee = _wasteCollectionFee;
        wasteTransportationFee = _wasteTransportationFee;
        wasteRecyclingFee = _wasteRecyclingFee;
        wasteCounter = 0;
    }

    function setFees(
        uint256 _wasteCollectionFee,
        uint256 _wasteTransportationFee,
        uint256 _wasteRecyclingFee
    ) external onlyOwner {
        wasteCollectionFee = _wasteCollectionFee;
        wasteTransportationFee = _wasteTransportationFee;
        wasteRecyclingFee = _wasteRecyclingFee;
    }

    function collectWaste(address wasteProducer, uint256 amount) external {
        require(amount > 0, "Waste amount should be greater than 0");
        celoToken.safeTransferFrom(wasteProducer, address(this), wasteCollectionFee);

        wasteCounter++;
        wastes[wasteCounter] = Waste(
            wasteCounter,
            amount,
            wasteProducer,
            address(0),
            address(0),
            true,
            false,
            false
        );

        emit WasteCollected(wasteCounter, wasteProducer, amount);
    }

    function transportWaste(uint256 wasteId, address transporter) external {
        Waste storage waste = wastes[wasteId];
        require(waste.isCollected, "Waste has not been collected yet");
        require(!waste.isTransported, "Waste has already been transported");
        celoToken.safeTransferFrom(transporter, address(this), wasteTransportationFee);
        waste.transporter = transporter;
        waste.isTransported = true;
        emit WasteTransported(wasteId, transporter, waste.amount);
    }

    function recycleWaste(uint256 wasteId, address recycler) external {
        Waste storage waste = wastes[wasteId];
        require(waste.isTransported, "Waste has not been transported yet");
        require(!waste.isRecycled, "Waste has already been recycled");
        celoToken.safeTransferFrom(recycler, address(this), wasteRecyclingFee);
        waste.recycler = recycler;
        waste.isRecycled = true;
emit WasteRecycled(wasteId, recycler, waste.amount);
}

function withdrawFees(address to) external onlyOwner {
    uint256 balance = celoToken.balanceOf(address(this));
    celoToken.safeTransfer(to, balance);
}
}
       
