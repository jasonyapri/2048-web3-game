// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.1.1 2024.03.12
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

contract Web3Game2048 {
    address public owner;
    uint256 public prizePool;

    enum Move {
        UP,
        DOWN,
        LEFT,
        RIGHT
    }

    event Movement(address player, Move move);

    uint16[4][4] public gameBoard;

    string public constant AUTHOR_NAME = "Jason Yapri";
    string public constant AUTHOR_WEBSITE = "https://jasonyapri.com";
    string public constant AUTHOR_LINKEDIN =
        "https://linkedin.com/in/jasonyapri";

    event DonationReceived(
        address indexed donator,
        string name,
        uint256 amount
    );

    struct TileLocation {
        uint8 row;
        uint8 column;
    }

    mapping(address => uint256) public donatorsList;

    uint8 public commissionPercentage;
    uint256 public prizePercentage;

    uint256 public moveCount;

    event Moved(uint16[4][4] updatedGameBoard);
    event PrizePoolIncreased(uint256 addedValue, uint256 updatedPrizePool);
    event YouHaveWonTheGame(
        address winner,
        uint256 moveCount,
        uint256 winnerPrize
    );
    event TilesReset();
    event GameOver();

    error NoAmountSent();
    error TransferFailed(address recipient, uint256 amount);

    constructor() payable {
        // Set the deployer of the contract as owner and set the initial prize pool amount from the amount received during deployment
        owner = msg.sender;
        prizePool = msg.value;
        prizePercentage = 50; // 50% of the prize pool amount
        commissionPercentage = 10; // 10% commission of each transfer

        resetTiles();
    }

    function resetTiles() internal {
        // Initialize the game board with empty tiles (0 value)
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                gameBoard[i][j] = 0;
            }
        }
        moveCount = 0;

        emit TilesReset();
    }

    function placeNewTile() internal returns (bool) {
        TileLocation[] memory emptyTiles = new TileLocation[](0);

        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 0)
                    emptyTiles[emptyTiles.length] = TileLocation(i, j);
            }
        }

        // Add Tile 2 to a random empty tile
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % emptyTiles.length;
        uint8 randomRow = emptyTiles[randomIndex].row;
        uint8 randomCol = emptyTiles[randomIndex].column;
        gameBoard[randomRow][randomCol] = 2;

        if (emptyTiles.length == 1) return false;

        return true;
    }

    function moveTilesUp() internal {
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = i;
                    // Move the value up until it reaches the top or another tile with a different value
                    while (k > 0 && gameBoard[k - 1][j] == 0) {
                        gameBoard[k - 1][j] = gameBoard[k][j];
                        gameBoard[k][j] = 0;
                        k--;
                    }
                    // Merge the value with the tile above if they have the same value
                    if (k > 0 && gameBoard[k - 1][j] == gameBoard[k][j]) {
                        gameBoard[k - 1][j] *= 2;
                        gameBoard[k][j] = 0;
                    }
                }
            }
        }
    }

    function moveTilesLeft() internal {
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = j;
                    // Move the value to the left until it reaches the leftmost column or another tile with a different value
                    while (k > 0 && gameBoard[i][k - 1] == 0) {
                        gameBoard[i][k - 1] = gameBoard[i][k];
                        gameBoard[i][k] = 0;
                        k--;
                    }
                    // Merge the value with the tile on the left if they have the same value
                    if (k > 0 && gameBoard[i][k - 1] == gameBoard[i][k]) {
                        gameBoard[i][k - 1] *= 2;
                        gameBoard[i][k] = 0;
                    }
                }
            }
        }
    }

    function moveTilesDown() internal {
        for (uint8 i = 3; i >= 0; i--) {
            for (uint8 j = 3; j >= 0; j--) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = i;
                    // Move the value down until it reaches the bottom or another tile with a different value
                    while (k < 3 && gameBoard[k + 1][j] == 0) {
                        gameBoard[k + 1][j] = gameBoard[k][j];
                        gameBoard[k][j] = 0;
                        k++;
                    }
                    // Merge the value with the tile below if they have the same value
                    if (k < 3 && gameBoard[k + 1][j] == gameBoard[k][j]) {
                        gameBoard[k + 1][j] *= 2;
                        gameBoard[k][j] = 0;
                    }
                }
            }
        }
    }

    function moveTilesRight() internal {
        for (uint8 i = 3; i >= 0; i--) {
            for (uint8 j = 3; j >= 0; j--) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = j;
                    // Move the value to the right until it reaches the rightmost column or another tile with a different value
                    while (k < 3 && gameBoard[i][k + 1] == 0) {
                        gameBoard[i][k + 1] = gameBoard[i][k];
                        gameBoard[i][k] = 0;
                        k++;
                    }
                    // Merge the value with the tile on the right if they have the same value
                    if (k < 3 && gameBoard[i][k + 1] == gameBoard[i][k]) {
                        gameBoard[i][k + 1] *= 2;
                        gameBoard[i][k] = 0;
                    }
                }
            }
        }
    }

    function makeMove(Move move) external {
        if (move == Move.UP) {
            moveTilesUp();
        } else if (move == Move.DOWN) {
            moveTilesDown();
        } else if (move == Move.LEFT) {
            moveTilesLeft();
        } else if (move == Move.RIGHT) {
            moveTilesRight();
        }
        emit Movement({player: msg.sender, move: move});
        moveCount++;
        emit Moved(gameBoard);

        if (won()) {
            distributePrize(msg.sender);
            resetTiles();
        } else {
            if (!placeNewTile()) {
                emit GameOver();
                resetTiles();
            }
        }
    }

    function donateToPrizePool(string calldata name) external payable {
        if (msg.value == 0) revert NoAmountSent();

        emit DonationReceived({
            donator: msg.sender,
            name: name,
            amount: msg.value
        });

        donatorsList[msg.sender] += msg.value;
        prizePool += msg.value;
    }

    function donateToOwner() external payable {
        if (msg.value == 0) revert NoAmountSent();

        (bool success, ) = payable(owner).call{value: msg.value}("");
        if (!success) revert TransferFailed(owner, msg.value);
    }

    function won() internal view returns (bool) {
        // Check if a player has reached the winning condition (2048 tile) only after making a move
        bool hasWon = false;
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 2048) {
                    hasWon = true;
                    break;
                }
            }
            if (hasWon) {
                break;
            }
        }
        return hasWon;
    }

    receive() external payable {}

    function emergencyExit() external {
        if (msg.sender == owner) {
            (bool success, ) = payable(owner).call{
                value: address(this).balance
            }("");
            if (!success) revert TransferFailed(owner, address(this).balance);
        }
    }

    function distributePrize(address winner) internal {
        // Transfer half of the prize pool amount to the winner's wallet address
        uint256 totalPrize = (prizePool * prizePercentage) / 100;
        uint256 commission = (totalPrize * commissionPercentage) / 100;
        uint256 winnerPrize = totalPrize - commission;

        prizePool -= totalPrize;
        (bool s1, ) = payable(owner).call{value: commission}("");
        if (!s1) revert TransferFailed(owner, commission);

        (bool s2, ) = payable(winner).call{value: winnerPrize}("");
        if (!s2) revert TransferFailed(winner, winnerPrize);

        emit YouHaveWonTheGame(winner, moveCount, winnerPrize);
    }
}
