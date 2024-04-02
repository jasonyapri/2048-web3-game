// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.8.0 (2024.04.02)
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Web3Game2048 is Ownable, ReentrancyGuard {
    using Address for address payable;

    mapping(address => uint256) public winnerPrizeBalance;
    uint256 public prizePool; // 32 bytes | slot 1
    uint256 internal commissionPool; // 32 bytes | slot 2
    uint256 public moveCount; // 32 bytes | slot 3
    uint16[4][4] public gameBoard; // 2 bytes | slot 4
    bool public firstPrizeDistributed; // 1 byte | slot 4
    bool public secondPrizeDistributed; // 1 byte | slot 4
    bool public thirdPrizeDistributed; // 1 byte | slot 4
    bool public fourthPrizeDistributed; // 1 byte | slot 4
    bool public fifthPrizeDistributed; // 1 byte | slot 4
    bool public sixthPrizeDistributed; // 1 byte | slot 4
    bool public stopped; // 1 byte | slot 4

    uint8 public constant GRAND_PRIZE_PERCENTAGE = 50; // 50% of the prize pool amount when reached 2048
    uint8 public constant FIRST_PRIZE_PERCENTAGE = 20; // 20% of the prize pool amount when reached 1024
    uint8 public constant SECOND_PRIZE_PERCENTAGE = 10; // 10% of the prize pool amount when reached 512
    uint8 public constant THIRD_PRIZE_PERCENTAGE = 5; // 5% of the prize pool amount when reached 256
    uint8 public constant FOURTH_PRIZE_PERCENTAGE = 3; // 3% of the prize pool amount when reached 128
    uint8 public constant FIFTH_PRIZE_PERCENTAGE = 2; // 2% of the prize pool amount when reached 64
    uint8 public constant SIXTH_PRIZE_PERCENTAGE = 1; // 1% of the prize pool amount when reached 32
    uint8 public constant COMMISSION_PERCENTAGE = 5; // 5% commission on every prize distribution
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
    event YouHaveWonTheGame(address indexed winner, uint256 moveCount);
    event YouWonAPrize(
        address winner,
        int8 prizeWon,
        uint256 moveCount,
        uint256 winnerPrize
    );
    event GameOver(uint256 moveCount);
    event DonationToPrizePoolReceived(
        address indexed donator,
        string name,
        uint256 amount
    );
    event DonationToAuthorReceived(
        address indexed donator,
        string name,
        uint256 amount
    );
    event TilesReset();
    event CircuitBreakerToggled(bool stopped);

    error NoValidMoveMade();
    error NoAmountSent();
    error NotAuthorized(address sender);
    error InvalidPercentage();
    error EmergencyLockIsActivated();
    error NoUnclaimedPrizeFound();
    error CommissionPoolEmpty();

    constructor(address owner) payable Ownable(owner) {
        // Set the initial prize pool amount from the amount received during deployment
        prizePool = msg.value;
        placeTwoNewTiles();
    }

    // Modifier to check if the circuit breaker is active
    modifier stopInEmergency() {
        if (stopped) revert EmergencyLockIsActivated();
        _;
    }

    function toggleCircuitBreaker() external onlyOwner {
        stopped = !stopped;
        emit CircuitBreakerToggled(stopped);
    }

    function calculateWinnerPrize(
        uint256 _remainingPrizePool,
        uint256 _prizePercentage
    ) internal pure returns (uint256 winnerPrize, uint256 remainingPrizePool) {
        uint256 totalPrize = (_remainingPrizePool * _prizePercentage) / 100;
        uint256 commission = (totalPrize * COMMISSION_PERCENTAGE) / 100;
        winnerPrize = totalPrize - commission;
        remainingPrizePool = _remainingPrizePool - totalPrize;
    }

    function calculatePrizesProjection()
        external
        view
        returns (
            uint256 sixthWinnerPrize,
            uint256 fifthWinnerPrize,
            uint256 fourthWinnerPrize,
            uint256 thirdWinnerPrize,
            uint256 secondWinnerPrize,
            uint256 firstWinnerPrize,
            uint256 grandWinnerPrize,
            uint256 finalRemainingPrizePool
        )
    {
        uint256 remainingPrizePool = prizePool;

        (sixthWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            SIXTH_PRIZE_PERCENTAGE
        );

        (fifthWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            FIFTH_PRIZE_PERCENTAGE
        );

        (fourthWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            FOURTH_PRIZE_PERCENTAGE
        );

        (thirdWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            THIRD_PRIZE_PERCENTAGE
        );

        (secondWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            SECOND_PRIZE_PERCENTAGE
        );

        (firstWinnerPrize, remainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            FIRST_PRIZE_PERCENTAGE
        );

        (grandWinnerPrize, finalRemainingPrizePool) = calculateWinnerPrize(
            remainingPrizePool,
            GRAND_PRIZE_PERCENTAGE
        );
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
        fourthPrizeDistributed = false;
        fifthPrizeDistributed = false;
        sixthPrizeDistributed = false;
    }

    function getGameBoardTile(
        uint256 row,
        uint256 col
    ) external view returns (uint16) {
        return gameBoard[row][col];
    }

    function placeTwoNewTiles() internal returns (bool) {
        TileLocation[] memory emptyTiles = new TileLocation[](16);

        uint256 emptyTilesCount = 0;
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

        uint256 emptyTilesCount = 0;
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
        for (int8 i = 3; i >= 0; i--) {
            uint8 p = uint8(i);
            for (int8 j = 3; j >= 0; j--) {
                uint8 q = uint8(j);
                if (gameBoard[p][q] != 0) {
                    uint8 k = q;
                    // Move the value to the right until it reaches the rightmost column or another tile with a different value
                    while (k < 3 && gameBoard[p][k + 1] == 0) {
                        gameBoard[p][k + 1] = gameBoard[p][k];
                        gameBoard[p][k] = 0;
                        k++;
                        moved = true;
                    }
                    // Merge the value with the tile on the right if they have the same value
                    if (k < 3 && gameBoard[p][k + 1] == gameBoard[p][k]) {
                        gameBoard[p][k + 1] *= 2;
                        gameBoard[p][k] = 0;
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

    function makeMove(Move move) external stopInEmergency {
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
            // Player won the grand prize!
            distributePrize(msg.sender, prizeWon);
            emit YouHaveWonTheGame(msg.sender, moveCount);
            resetGame();
        } else if (prizeWon > 0) {
            // Player won other prizes
            distributePrize(msg.sender, prizeWon);
            placeNewTile();
            if (!checkForValidMove()) {
                emit GameOver(moveCount);
                resetGame();
            }
        } else {
            // Game continues as usual
            placeNewTile();
            if (!checkForValidMove()) {
                emit GameOver(moveCount);
                resetGame();
            }
        }
    }

    function donateToPrizePool(
        string calldata name
    ) external payable stopInEmergency {
        if (msg.value == 0) revert NoAmountSent();

        prizePool += msg.value;

        emit DonationToPrizePoolReceived({
            donator: msg.sender,
            name: name,
            amount: msg.value
        });
    }

    function donateToAuthor(
        string calldata name
    ) external payable nonReentrant stopInEmergency {
        if (msg.value == 0) revert NoAmountSent();

        payable(owner()).sendValue(msg.value);

        emit DonationToAuthorReceived({
            donator: msg.sender,
            name: name,
            amount: msg.value
        });
    }

    function checkIfPlayerWonPrize() internal returns (int8) {
        // Check if a player has reached certain tile for the first time
        // Winning Prize Conditions:
        // 0 -> 2048
        // 1 -> 1024
        // 2 -> 512
        // 3 -> 256
        // 4 -> 128
        // 5 -> 64
        // 6 -> 32
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
                } else if (gameBoard[i][j] == 128 && !fourthPrizeDistributed) {
                    fourthPrizeDistributed = true;
                    return 4;
                } else if (gameBoard[i][j] == 64 && !fifthPrizeDistributed) {
                    fifthPrizeDistributed = true;
                    return 5;
                } else if (gameBoard[i][j] == 32 && !sixthPrizeDistributed) {
                    sixthPrizeDistributed = true;
                    return 6;
                }
            }
        }
        return -1;
    }

    receive() external payable {}

    function emergencyExit(
        uint256 percentage
    ) external onlyOwner nonReentrant stopInEmergency {
        if (percentage < 1 || percentage > 100) revert InvalidPercentage();
        uint256 amount = (address(this).balance * percentage) / 100;
        payable(owner()).sendValue(amount);
    }

    function distributePrize(
        address winner,
        int8 prizeWon
    ) internal nonReentrant {
        uint8 prizePercentage;
        if (prizeWon == 0) {
            prizePercentage = GRAND_PRIZE_PERCENTAGE;
        } else if (prizeWon == 1) {
            prizePercentage = FIRST_PRIZE_PERCENTAGE;
        } else if (prizeWon == 2) {
            prizePercentage = SECOND_PRIZE_PERCENTAGE;
        } else if (prizeWon == 3) {
            prizePercentage = THIRD_PRIZE_PERCENTAGE;
        } else if (prizeWon == 4) {
            prizePercentage = FOURTH_PRIZE_PERCENTAGE;
        } else if (prizeWon == 5) {
            prizePercentage = FIFTH_PRIZE_PERCENTAGE;
        } else if (prizeWon == 6) {
            prizePercentage = SIXTH_PRIZE_PERCENTAGE;
        }

        // Transfer certain percentage of the prize pool amount to the winner's wallet address
        uint256 totalPrize = (prizePool * prizePercentage) / 100;
        uint256 commission = (totalPrize * COMMISSION_PERCENTAGE) / 100;
        uint256 winnerPrize = totalPrize - commission;

        prizePool -= totalPrize;
        commissionPool += commission;
        winnerPrizeBalance[winner] += winnerPrize;

        emit YouWonAPrize(winner, prizeWon, moveCount, winnerPrize);
    }

    function getCommissionPool() external view onlyOwner returns (uint256) {
        return commissionPool;
    }

    function withdrawCommission() external onlyOwner nonReentrant {
        if (commissionPool == 0) revert CommissionPoolEmpty();
        uint256 amount = commissionPool;
        commissionPool = 0;
        payable(owner()).sendValue(amount);
    }

    function withdrawWinnerPrize() external nonReentrant {
        if (winnerPrizeBalance[msg.sender] == 0) revert NoUnclaimedPrizeFound();
        uint256 amount = winnerPrizeBalance[msg.sender];
        winnerPrizeBalance[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
    }
}
