import React from "react";
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, getKeyValue } from "@nextui-org/react";

const MoveCount = ({ moveCount }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const rows = [
        { timestamp: '2024-04-10 | 17:00', address: '0x123456', move: 'Up' },
        { timestamp: '2024-04-10 | 17:05', address: '0x123456', move: 'Down' },
    ];

    const columns = [
        { key: "timestamp", label: "Timestamp" },
        { key: "address", label: "Address" },
        { key: "move", label: "Move" },
    ];

    const openModal = () => {

    };

    const closeModal = () => {

    };

    const stopPropagation = (e) => {
        e.stopPropagation();
    };

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
                                <Table color="danger">
                                    <TableHeader>
                                        {columns.map((column) => (
                                            <TableColumn key={column.key}>{column.label}</TableColumn>
                                        ))}
                                    </TableHeader>
                                    <TableBody>
                                        {rows.length > 0 ? (rows.map((row, index) => (
                                            <TableRow key={index} onPress={openModal}>
                                                {columns.map((column) => (
                                                    <TableCell key={column.key}>{getKeyValue(row, column.key)}</TableCell>
                                                ))}
                                            </TableRow>
                                        ))) : (
                                            <TableRow>
                                                <TableCell colSpan={columns.length}>No data found</TableCell>
                                                <TableCell className="hidden"> </TableCell>
                                                <TableCell className="hidden"> </TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            </ModalBody>
                            <ModalFooter>
                                <Button color="danger" variant="light" onPress={onClose}>
                                    Close
                                </Button>
                            </ModalFooter>
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    );
};

export default MoveCount;