'use client';

import { React, useEffect, useState, useMemo } from "react";
import { toast } from 'react-toastify';
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, Pagination } from "@nextui-org/react";
import { ethers } from 'ethers';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import moment from 'moment';
import { useContractEvent } from 'wagmi';
import Confetti from 'react-confetti'

const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);

const MoveCount = ({ moveCount, address, width, height }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const [showConfetti, setShowConfetti] = useState(false);

    useContractEvent({
        ...Web3Game2048ContractData,
        eventName: 'GameOver',
        async listener(gameOverEvents) {
            await Promise.all(gameOverEvents.map(async (gameOverEvent) => {
                toast.error(`Game Over after ${gameOverEvent.args.moveCount} moves.`);
            }));
        },
    });

    useContractEvent({
        ...Web3Game2048ContractData,
        eventName: 'YouHaveWonTheGame',
        async listener(gameWonEvents) {
            await Promise.all(gameWonEvents.map(async (gameWonEvent) => {
                const subject = (gameWonEvent.args.winner == address) ? 'You' : 'Someone';
                toast(`${subject} has won the game!`);
            }));
        },
    });

    useContractEvent({
        ...Web3Game2048ContractData,
        eventName: 'YouWonAPrize',
        async listener(prizeWonEvents) {
            await Promise.all(prizeWonEvents.map(async (prizeWonEvent) => {

                setShowConfetti(true);

                const subject = (prizeWonEvent.args.winner == address) ? 'You' : 'Someone';
                const prizeWon = prizeWonEvent.args.prizeWon;
                let prizeLabel;
                switch (prizeWon) {
                    case 0:
                        prizeLabel = 'grand prize! (2048)';
                        break;
                    case 1:
                        prizeLabel = '1st prize! (1024)';
                        break;
                    case 2:
                        prizeLabel = '2nd prize! (512)';
                        break;
                    case 3:
                        prizeLabel = '3rd prize! (256)';
                        break;
                    case 4:
                        prizeLabel = '4th prize! (128)';
                        break;
                    case 5:
                        prizeLabel = '5th prize! (64)';
                        break;
                    case 6:
                        prizeLabel = '6th prize! (32)';
                        break;
                    default:
                        prizeLabel = 'unknown prize! (?)';
                }

                toast(`${subject} won the ${prizeLabel}`);

                setTimeout(() => {
                    setShowConfetti(false);
                }, 10000);
            }));
        },
    });

    const [moveHistory, setMoveHistory] = useState([]);
    const [isFetchingMoveHistory, setIsFetchingMoveHistory] = useState(false);

    useEffect(() => {
        // const fetchMoveHistory = async () => {
        //     setIsFetchingMoveHistory(true);

        //     // Connect to the contract
        //     let contract = new ethers.Contract(Web3Game2048ContractData.address, Web3Game2048ContractData.abi, provider);

        //     // Get the event filter
        //     let filter = contract.filters.Moved(); // Replace "EventName" with your event name

        //     // Get the event logs
        //     let logs = await provider.getLogs({
        //         fromBlock: 0,
        //         toBlock: 'latest',
        //         address: contract.address,
        //         topics: filter.topics,
        //     });

        //     // Parse the logs and get block details
        //     let events = await Promise.all(logs.map(async (log) => {
        //         let event = contract.interface.parseLog(log);
        //         let block = await provider.getBlock(log.blockNumber);
        //         return {
        //             move: event.args.move,
        //             player: event.args.player,
        //             blockNumber: log.blockNumber,
        //             timestamp: block.timestamp
        //         };
        //     }));

        //     setMoveHistory(events.reverse());
        //     setIsFetchingMoveHistory(false);
        // };

        // fetchMoveHistory();
    }, []);

    const getMoveLabel = (move) => {
        switch (move) {
            case 0:
                return 'Up';
            case 1:
                return 'Down';
            case 2:
                return 'Left';
            case 3:
                return 'Right';
            default:
                return 'Unknown';
        }
    };

    useContractEvent({
        ...Web3Game2048ContractData,
        eventName: 'Moved',
        async listener(newMoveEvents) {
            await Promise.all(newMoveEvents.map(async (newMoveEvent) => {
                let block = provider.getBlock(parseInt(newMoveEvent.blockNumber)); try {
                    // Call your smart contract function here
                    // For example:
                    // await contract.someFunction();
                } catch (error) {
                    if (error.code === 'CALL_EXCEPTION') {
                        console.log('The function was reverted.');
                    } else {
                        console.log('An unknown error occurred:', error);
                    }
                }
                const newMove = {
                    timestamp: moment.unix(block.timestamp).format('MMMM D, YYYY | HH:mm'),
                    player: newMoveEvent.args.player,
                    blockNumber: newMoveEvent.blockNumber,
                    move: newMoveEvent.args.move,
                    subject: (newMoveEvent.args.player == address) ? 'You' : 'Someone',
                }
                toast.success(`${newMove.subject} moved the tiles ${getMoveLabel(newMove.move)}.`);
                setMoveHistory(prevMoveHistory => [newMove, ...prevMoveHistory]);
            }));
        },
    });

    const dummyMoveHistory = [
        { timestamp: 'April 10, 2024 | 17:00', player: '0x123456', move: 'Up' },
        { timestamp: 'April 10, 2024 | 17:05', player: '0x123456', move: 'Down' },
    ];

    const [page, setPage] = useState(1);
    const rowsPerPage = 5;

    const pages = Math.ceil(moveHistory.length / rowsPerPage);

    const items = useMemo(() => {
        const start = (page - 1) * rowsPerPage;
        const end = start + rowsPerPage;

        return moveHistory.slice(start, end);
    }, [page, moveHistory]);


    const columns = [
        { key: "timestamp", label: "Date Time" },
        { key: "player", label: "Player" },
        { key: "move", label: "Move" },
    ];

    return (
        <>
            <Button className="move-count" onPress={false && onOpen}>
                <span className="move-count-title">MOVE COUNT</span>
                <div className="move-count-number">{moveCount.toString()}</div>
            </Button>

            {showConfetti && (
                <Confetti
                    width={width}
                    height={height}
                />
            )}

            <Modal
                isOpen={isOpen}
                onOpenChange={onOpenChange}
                placement="center"
                classNames={{
                    header: "bg-theme-header",
                    body: "bg-theme-header",
                    footer: "bg-theme-header",
                }}
            >
                <ModalContent>
                    {(onClose) => (
                        <>
                            <ModalHeader className="flex flex-col gap-1">Move History</ModalHeader>
                            <ModalBody>
                                <Table
                                    isStriped={true}
                                    color="danger"
                                    bottomContent={
                                        pages > 0 ? (
                                            <div className="flex w-full justify-center">
                                                <Pagination
                                                    isCompact
                                                    showControls
                                                    showShadow
                                                    color="primary"
                                                    page={page}
                                                    total={pages}
                                                    onChange={(page) => setPage(page)}
                                                />
                                            </div>
                                        ) : null
                                    }
                                >
                                    <TableHeader>
                                        {columns.map((column) => (
                                            <TableColumn key={column.key}>{column.label}</TableColumn>
                                        ))}
                                    </TableHeader>
                                    <TableBody>
                                        {items.length > 0 ?
                                            (items.map((item, index) => (
                                                <TableRow key={index}>
                                                    <TableCell key="timestamp">{moment.unix(item.timestamp).format('MMMM D, YYYY | HH:mm')}</TableCell>
                                                    <TableCell key="player">
                                                        <a href={process.env.ETHERSCAN_URL + item.player} target="_blank" rel="noopener noreferrer">
                                                            {`${item.player.slice(0, 6)}...${item.player.slice(-4)}`}
                                                        </a>
                                                    </TableCell>
                                                    <TableCell key="move">{getMoveLabel(item.move)}</TableCell>
                                                </TableRow>
                                            ))) : (
                                                <TableRow>
                                                    <TableCell colSpan={columns.length}>{isFetchingMoveHistory ? "Fetching data..." : "No data found"}</TableCell>
                                                    <TableCell className="hidden"> </TableCell>
                                                    <TableCell className="hidden"> </TableCell>
                                                </TableRow>
                                            )}
                                    </TableBody>
                                </Table>
                            </ModalBody>
                            <ModalFooter />
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    );
};

export default MoveCount;