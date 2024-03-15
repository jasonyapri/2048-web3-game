// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.2.4 (2024.03.15)
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

contract Web3Game2048 {
    uint256 public prizePool; // 32 bytes | slot 1
    uint256 public moveCount; // 32 bytes | slot 2
    address public owner; // 20 bytes | slot 3
    uint16[4][4] public gameBoard; // 2 bytes | slot 3
    bool public firstPrizeDistributed; // 1 byte | slot 3
    bool public secondPrizeDistributed; // 1 byte | slot 3
    bool public thirdPrizeDistributed; // 1 byte | slot 3

    uint8 public constant GRAND_PRIZE_PERCENTAGE = 50; // 50% of the prize pool amount when reached 2048
    uint8 public constant FIRST_PRIZE_PERCENTAGE = 10; // 10% of the prize pool amount when reached 1024
    uint8 public constant SECOND_PRIZE_PERCENTAGE = 5; // 5% of the prize pool amount when reached 512
    uint8 public constant THIRD_PRIZE_PERCENTAGE = 3; // 3% of the prize pool amount when reached 256
    uint8 public constant COMMISSION_PERCENTAGE = 10; // 10% commission on every prize distribution
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
    error NotAuthorized(address sender);

    constructor() payable {
        // Set the initial prize pool amount from the amount received during deployment
        owner = msg.sender;
        prizePool = msg.value;
        placeTwoNewTiles();
    }

    function resetGame() internal {
        // Reset Tiles
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                gameBoard[i][j] = 0;
            }
        }
        moveCount = 0;
        emit TilesReset();

        placeTwoNewTiles();

        firstPrizeDistributed = false;
        secondPrizeDistributed = false;
        thirdPrizeDistributed = false;
    }

    function getGameBoardTile(
        uint row,
        uint col
    ) external view returns (uint16) {
        return gameBoard[row][col];
    }

    function placeTwoNewTiles() internal returns (bool) {
        TileLocation[] memory emptyTiles = new TileLocation[](16);

        uint emptyTilesCount = 0;
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 0) {
                    emptyTiles[emptyTilesCount] = TileLocation(i, j);
                    emptyTilesCount++;
                }
            }
        }

        if (emptyTilesCount == 0) return false;

        // Add Tile 2 to two random empty tiles
        uint256 randomIndex1 = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    "randomIndex1"
                )
            )
        ) % emptyTilesCount;
        uint256 randomIndex2;
        uint8 counter = 0;
        do {
            randomIndex2 =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.prevrandao,
                            "randomIndex2",
                            counter
                        )
                    )
                ) %
                emptyTilesCount;
            counter++;
        } while (randomIndex1 == randomIndex2 && counter < emptyTilesCount);

        uint8 randomRow1 = emptyTiles[randomIndex1].row;
        uint8 randomCol1 = emptyTiles[randomIndex1].column;
        uint8 randomRow2 = emptyTiles[randomIndex2].row;
        uint8 randomCol2 = emptyTiles[randomIndex2].column;
        gameBoard[randomRow1][randomCol1] = 2;
        gameBoard[randomRow2][randomCol2] = 2;

        return true;
    }

    function placeNewTile() internal returns (bool) {
        TileLocation[] memory emptyTiles = new TileLocation[](16);

        uint emptyTilesCount = 0;
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 0) {
                    emptyTiles[emptyTilesCount] = TileLocation(i, j);
                    emptyTilesCount++;
                }
            }
        }

        if (emptyTilesCount == 0) return false;

        // Add Tile 2 to a random empty tile
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, moveCount)
            )
        ) % emptyTilesCount;
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
        for (int8 i = 3; i >= 0; i--) {
            uint8 p = uint8(i);
            for (int8 j = 3; j >= 0; j--) {
                uint8 q = uint8(j);
                if (gameBoard[p][q] != 0) {
                    uint8 k = p;
                    // Move the value down until it reaches the bottom or another tile with a different value
                    while (k < 3 && gameBoard[k + 1][q] == 0) {
                        gameBoard[k + 1][q] = gameBoard[k][q];
                        gameBoard[k][q] = 0;
                        k++;
                        moved = true;
                    }
                    // Merge the value with the tile below if they have the same value
                    if (k < 3 && gameBoard[k + 1][q] == gameBoard[k][q]) {
                        gameBoard[k + 1][q] *= 2;
                        gameBoard[k][q] = 0;
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

        int8 prizeWon = checkIfPlayerWonPrize();
        if (prizeWon == 0) {
            distributePrize(msg.sender, prizeWon);
            resetGame();
        } else if (prizeWon > 0) {
            distributePrize(msg.sender, prizeWon);
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

    function checkIfPlayerWonPrize() internal returns (int8) {
        // Check if a player has reached certain tile for the first time
        // Winning Prize Conditions:
        // 0 -> 2048
        // 1 -> 1024
        // 2 -> 512
        // 3 -> 256
        for (uint8 i = 0; i < 4; i++) {
            for (uint8 j = 0; j < 4; j++) {
                if (gameBoard[i][j] == 2048) {
                    return 0;
                } else if (gameBoard[i][j] == 1024 && !firstPrizeDistributed) {
                    firstPrizeDistributed = true;
                    return 1;
                } else if (gameBoard[i][j] == 512 && !secondPrizeDistributed) {
                    secondPrizeDistributed = true;
                    return 2;
                } else if (gameBoard[i][j] == 256 && !thirdPrizeDistributed) {
                    thirdPrizeDistributed = true;
                    return 3;
                }
            }
        }
        return -1;
    }

    receive() external payable {}

    function emergencyExit() external {
        if (msg.sender == owner) {
            (bool success, ) = payable(owner).call{
                value: address(this).balance
            }("");
            if (!success) revert TransferFailed(owner, address(this).balance);
        } else {
            revert NotAuthorized(msg.sender);
        }
    }

    function distributePrize(address winner, int8 prizeWon) internal {
        uint8 prizePercentage;
        if (prizeWon == 0) {
            prizePercentage = GRAND_PRIZE_PERCENTAGE;
        } else if (prizeWon == 1) {
            prizePercentage = FIRST_PRIZE_PERCENTAGE;
        } else if (prizeWon == 2) {
            prizePercentage = SECOND_PRIZE_PERCENTAGE;
        } else if (prizeWon == 3) {
            prizePercentage = THIRD_PRIZE_PERCENTAGE;
        }

        // Transfer certain percentage of the prize pool amount to the winner's wallet address
        uint256 totalPrize = (prizePool * prizePercentage) / 100;
        uint256 commission = (totalPrize * COMMISSION_PERCENTAGE) / 100;
        uint256 winnerPrize = totalPrize - commission;

        prizePool -= totalPrize;
        (bool s1, ) = payable(owner).call{value: commission}("");
        if (!s1) revert TransferFailed(owner, commission);

        (bool s2, ) = payable(winner).call{value: winnerPrize}("");
        if (!s2) revert TransferFailed(winner, winnerPrize);

        emit YouHaveWonTheGame(winner, moveCount, winnerPrize);
    }
}
