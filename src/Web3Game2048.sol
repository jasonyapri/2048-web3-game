// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.1.1 2024.03.12
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

contract Web3Game2048 {
    uint256 public prizePool; // 32 bytes | slot 1
    uint256 public moveCount; // 32 bytes | slot 2
    address public owner; // 20 bytes | slot 3
    uint16[4][4] public gameBoard; // 2 bytes | slot 3

    uint256 public constant prizePercentage = 50; // 50% of the prize pool amount;
    uint8 public constant commissionPercentage = 10; // 10% commission of each transfer
    string public constant AUTHOR_NAME = "Jason Yapri";
    string public constant AUTHOR_WEBSITE = "https://jasonyapri.com";
    string public constant AUTHOR_LINKEDIN =
        "https://linkedin.com/in/jasonyapri";

    struct TileLocation {
        uint8 row;
        uint8 column;
    }

    enum Move {
        UP,
        DOWN,
        LEFT,
        RIGHT
    }

    event Moved(address player, Move move);
    event YouHaveWonTheGame(
        address winner,
        uint256 moveCount,
        uint256 winnerPrize
    );
    event DonationReceived(
        address indexed donator,
        string name,
        uint256 amount
    );
    event TilesReset();

    error NoValidMoveMade();
    error NoAmountSent();
    error TransferFailed(address recipient, uint256 amount);

    constructor() payable {
        // Set the initial prize pool amount from the amount received during deployment
        owner = msg.sender;
        prizePool = msg.value;
        placeNewTile();
    }

    function resetGame() internal {
        resetTiles();
        placeNewTile();
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

        if (emptyTiles.length == 0) return false;

        // Add Tile 2 to a random empty tile
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % emptyTiles.length;
        uint8 randomRow = emptyTiles[randomIndex].row;
        uint8 randomCol = emptyTiles[randomIndex].column;
        gameBoard[randomRow][randomCol] = 2;

        return true;
    }

    function moveTilesUp() internal returns (bool) {
        bool moved = false;
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = i;
                    // Move the value up until it reaches the top or another tile with a different value
                    while (k > 0 && gameBoard[k - 1][j] == 0) {
                        gameBoard[k - 1][j] = gameBoard[k][j];
                        gameBoard[k][j] = 0;
                        k--;
                        moved = true;
                    }
                    // Merge the value with the tile above if they have the same value
                    if (k > 0 && gameBoard[k - 1][j] == gameBoard[k][j]) {
                        gameBoard[k - 1][j] *= 2;
                        gameBoard[k][j] = 0;
                        moved = true;
                    }
                }
            }
        }
        return moved;
    }

    function moveTilesLeft() internal returns (bool) {
        bool moved = false;
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = j;
                    // Move the value to the left until it reaches the leftmost column or another tile with a different value
                    while (k > 0 && gameBoard[i][k - 1] == 0) {
                        gameBoard[i][k - 1] = gameBoard[i][k];
                        gameBoard[i][k] = 0;
                        k--;
                        moved = true;
                    }
                    // Merge the value with the tile on the left if they have the same value
                    if (k > 0 && gameBoard[i][k - 1] == gameBoard[i][k]) {
                        gameBoard[i][k - 1] *= 2;
                        gameBoard[i][k] = 0;
                        moved = true;
                    }
                }
            }
        }
        return moved;
    }

    function moveTilesDown() internal returns (bool) {
        bool moved = false;
        for (uint8 i = 3; i >= 0; i--) {
            for (uint8 j = 3; j >= 0; j--) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = i;
                    // Move the value down until it reaches the bottom or another tile with a different value
                    while (k < 3 && gameBoard[k + 1][j] == 0) {
                        gameBoard[k + 1][j] = gameBoard[k][j];
                        gameBoard[k][j] = 0;
                        k++;
                        moved = true;
                    }
                    // Merge the value with the tile below if they have the same value
                    if (k < 3 && gameBoard[k + 1][j] == gameBoard[k][j]) {
                        gameBoard[k + 1][j] *= 2;
                        gameBoard[k][j] = 0;
                        moved = true;
                    }
                }
            }
        }
        return moved;
    }

    function moveTilesRight() internal returns (bool) {
        bool moved;
        for (uint8 i = 3; i >= 0; i--) {
            for (uint8 j = 3; j >= 0; j--) {
                if (gameBoard[i][j] != 0) {
                    uint8 k = j;
                    // Move the value to the right until it reaches the rightmost column or another tile with a different value
                    while (k < 3 && gameBoard[i][k + 1] == 0) {
                        gameBoard[i][k + 1] = gameBoard[i][k];
                        gameBoard[i][k] = 0;
                        k++;
                        moved = true;
                    }
                    // Merge the value with the tile on the right if they have the same value
                    if (k < 3 && gameBoard[i][k + 1] == gameBoard[i][k]) {
                        gameBoard[i][k + 1] *= 2;
                        gameBoard[i][k] = 0;
                        moved = true;
                    }
                }
            }
        }
        return moved;
    }

    function checkForValidMove() internal view returns (bool) {
        bool validMoveExists;
        // check if there is any empty tile or two adjacent tiles with the same value
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 0) {
                    validMoveExists = true;
                    break;
                }
                if (
                    (i < 3 && gameBoard[i][j] == gameBoard[i + 1][j]) ||
                    (j < 3 && gameBoard[i][j] == gameBoard[i][j + 1])
                ) {
                    validMoveExists = true;
                    break;
                }
            }
            if (validMoveExists) {
                break;
            }
        }
        return validMoveExists;
    }

    function makeMove(Move move) external {
        bool moved = false;
        if (move == Move.UP) {
            moved = moveTilesUp();
        } else if (move == Move.DOWN) {
            moved = moveTilesDown();
        } else if (move == Move.LEFT) {
            moved = moveTilesLeft();
        } else if (move == Move.RIGHT) {
            moved = moveTilesRight();
        }
        if (!moved) revert NoValidMoveMade();
        moveCount++;
        emit Moved({player: msg.sender, move: move});

        if (won()) {
            distributePrize(msg.sender);
            resetGame();
        } else {
            placeNewTile();
            if (!checkForValidMove()) resetGame();
        }
    }

    function donateToPrizePool(string calldata name) external payable {
        if (msg.value == 0) revert NoAmountSent();

        emit DonationReceived({
            donator: msg.sender,
            name: name,
            amount: msg.value
        });

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
