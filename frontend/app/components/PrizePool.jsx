'use client';

import { React, useEffect, useState, useMemo } from "react";
import { toast } from 'react-toastify';
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, Pagination } from "@nextui-org/react";
import { Card, CardBody, CardFooter, Image } from "@nextui-org/react";
import { ethers } from 'ethers';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import moment from 'moment';
import { useContractEvent, useContractRead, useContractReads } from 'wagmi';

const provider = new ethers.providers.JsonRpcProvider(process.env.NEXT_PUBLIC_OPTIMISM_SEPOLIA_RPC_URL);

const PrizePool = ({ prizePoolInEth }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const { data: rawPrizesProjection, isError: fetchPrizesProjectionIsError, isLoading: fetchPrizesProjectionIsLoading } = useContractRead({
        ...Web3Game2048ContractData,
        functionName: 'calculatePrizesProjection',
        watch: true
    });

    const prizeDistributedContracts = [
        {
            ...Web3Game2048ContractData,
            functionName: 'firstPrizeDistributed',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'secondPrizeDistributed',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'thirdPrizeDistributed',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'fourthPrizeDistributed',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'fifthPrizeDistributed',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'sixthPrizeDistributed',
        },
    ];

    const { data: rawPrizeDistributedFlags, isError: fetchPrizeDistributedFlagsIsError, isLoading: fetchPrizeDistributedFlagsIsLoading } = useContractReads({
        contracts: prizeDistributedContracts,
        watch: true
    });

    const placeholderPrizeList = [
        {
            title: "32",
            img: "/img/prize-tiles/32.png",
            prize: "✅ Won!",
        },
        {
            title: "64",
            img: "/img/prize-tiles/64.png",
            prize: "8 ETH",
        },
        {
            title: "128",
            img: "/img/prize-tiles/128.png",
            prize: "10.00 ETH",
        },
        {
            title: "256",
            img: "/img/prize-tiles/256.png",
            prize: "12.50 ETH",
        },
        {
            title: "512",
            img: "/img/prize-tiles/512.png",
            prize: "15.70 ETH",
        },
        {
            title: "1024",
            img: "/img/prize-tiles/1024.png",
            prize: "18.00 ETH",
        },
        {
            title: "2048",
            img: "/img/prize-tiles/2048.png",
            prize: "19.50 ETH",
        },
    ];

    const [prizeList, setPrizeList] = useState(placeholderPrizeList);

    useEffect(() => {

        if (rawPrizeDistributedFlags && rawPrizesProjection) {
            const prizeDistributedFlags = [...rawPrizeDistributedFlags.map(item => item.result).reverse(), false];

            let currentPrizeList = prizeList;
            for (let i = 0; i < prizeList.length; i++) {
                if (prizeDistributedFlags[i]) {
                    currentPrizeList[i].prize = "✅ Won!"
                } else {
                    currentPrizeList[i].prize = parseFloat(ethers.utils.formatEther(rawPrizesProjection[i])).toFixed(6).toString() + " ETH";
                }
            }
            setPrizeList(currentPrizeList);
        }
    }, [rawPrizesProjection, rawPrizeDistributedFlags]);

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
                                Anyone who reach the following tile will be rewarded with ETH from the Prize Pool !
                                <div className="gap-4 grid grid-cols-3 sm:grid-cols-3">
                                    {prizeList.map((item, index) => (
                                        <Card shadow="sm" key={index}>
                                            <CardBody className="overflow-visible p-1">
                                                <Image
                                                    shadow="sm"
                                                    width="100%"
                                                    alt={item.title}
                                                    className="w-full object-cover"
                                                    src={item.img}
                                                />
                                            </CardBody>
                                            <CardFooter className="text-small justify-center">
                                                <p>{item.prize}</p>
                                            </CardFooter>
                                        </Card>
                                    ))}
                                </div>
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