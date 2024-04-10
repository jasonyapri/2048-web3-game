'use client';

import { React, useEffect, useState, useMemo } from "react";
import { toast } from 'react-toastify';
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, Pagination } from "@nextui-org/react";
import { ethers } from 'ethers';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import moment from 'moment';
import { useContractEvent } from 'wagmi';

const provider = new ethers.providers.JsonRpcProvider(process.env.NEXT_PUBLIC_OPTIMISM_SEPOLIA_RPC_URL);

const PrizePool = ({ prizePoolInEth }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    return (
        <>
            <Button className="prize-pool" onPress={onOpen}>
                <span className="prize-pool-title">PRIZE POOL</span>
                <div className="prize-pool-amount">{prizePoolInEth.toString()} ETH</div>
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
                            <ModalHeader className="flex flex-col gap-1">Prizes</ModalHeader>
                            <ModalBody>

                            </ModalBody>
                            <ModalFooter />
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    );
};

export default PrizePool;