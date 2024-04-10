'use client';

import { React, useEffect, useState, useMemo } from "react";
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, Pagination, getKeyValue } from "@nextui-org/react";
import { ethers } from 'ethers';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import moment from 'moment';

const MoveCount = ({ moveCount }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const [moveHistory, setMoveHistory] = useState([]);
    const [isFetchingMoveHistory, setIsFetchingMoveHistory] = useState(false);

    useEffect(() => {
        const fetchMoveHistory = async () => {
            setIsFetchingMoveHistory(true);
            // Connect to the provider
            let provider = new ethers.providers.JsonRpcProvider(process.env.NEXT_PUBLIC_OPTIMISM_SEPOLIA_RPC_URL);

            // Connect to the contract
            let contract = new ethers.Contract(Web3Game2048ContractData.address, Web3Game2048ContractData.abi, provider);

            // Get the event filter
            let filter = contract.filters.Moved(); // Replace "EventName" with your event name

            // Get the event logs
            let logs = await provider.getLogs({
                fromBlock: 0,
                toBlock: 'latest',
                address: contract.address,
                topics: filter.topics,
            });

            // Parse the logs and get block details
            let events = await Promise.all(logs.map(async (log) => {
                let event = contract.interface.parseLog(log);
                let block = await provider.getBlock(log.blockNumber);
                return {
                    move: event.args.move,
                    player: event.args.player,
                    blockNumber: log.blockNumber,
                    timestamp: block.timestamp
                };
            }));

            setMoveHistory(events.reverse());
            setIsFetchingMoveHistory(false);
        };

        fetchMoveHistory();
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
            <Button className="move-count" onPress={onOpen}>
                <span className="move-count-title">MOVE COUNT</span>
                <div className="move-count-number">{moveCount.toString()}</div>
            </Button>

            <Modal
                isOpen={isOpen}
                onOpenChange={onOpenChange}
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
                                                        <a href={process.env.NEXT_PUBLIC_OPTIMISM_SEPOLIA_ETHERSCAN_URL + item.player} target="_blank" rel="noopener noreferrer">
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