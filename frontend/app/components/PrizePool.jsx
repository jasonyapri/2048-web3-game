'use client';

import { React, useEffect, useState, useMemo } from "react";
import { toast } from 'react-toastify';
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure, Tooltip, Kbd, Divider } from "@nextui-org/react";
import { Table, TableHeader, TableColumn, TableBody, TableRow, TableCell, Pagination } from "@nextui-org/react";
import { Card, CardBody, CardFooter, Image } from "@nextui-org/react";
import { ethers, BigNumber } from 'ethers';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import moment from 'moment';
import { useContractEvent, useContractRead, useContractReads, useContractWrite } from 'wagmi';

const provider = new ethers.providers.JsonRpcProvider(process.env.NEXT_PUBLIC_OPTIMISM_SEPOLIA_RPC_URL);

const PrizePool = ({ prizePoolInEth, address }) => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const { data: rawWinnerPrizeBalance, isError: fetchWinnerPrizeBalanceIsError, isLoading: fetchWinnerPrizeBalanceIsLoading, refetch: refetchWinnerPrizeBalance } = useContractRead({
        ...Web3Game2048ContractData,
        functionName: 'winnerPrizeBalance',
        args: [address]
    });

    useEffect(() => {
        if (address) {
            refetchWinnerPrizeBalance();
        }
    }, [address]);

    const [winnerPrizeBalance, setWinnerPrizeBalance] = useState(0);

    useEffect(() => {
        if (address && rawWinnerPrizeBalance !== undefined) {
            if (rawWinnerPrizeBalance == BigInt(0)) {
                setWinnerPrizeBalance(0);
            } else {
                setWinnerPrizeBalance(parseFloat(ethers.utils.formatEther(rawWinnerPrizeBalance)).toFixed(6));
            }
        }
    }, [rawWinnerPrizeBalance]);

    const { data: rawPrizesProjection, isError: fetchPrizesProjectionIsError, isLoading: fetchPrizesProjectionIsLoading } = useContractRead({
        ...Web3Game2048ContractData,
        functionName: 'calculatePrizesProjection',
        watch: true
    });

    const prizePercentageContracts = [
        {
            ...Web3Game2048ContractData,
            functionName: 'SIXTH_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'FIFTH_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'FOURTH_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'THIRD_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'SECOND_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'FIRST_PRIZE_PERCENTAGE',
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'GRAND_PRIZE_PERCENTAGE',
        },
    ];

    const { data: rawPrizePercentage, isError: fetchPrizePercentageIsError, isLoading: fetchPrizePercentageIsLoading } = useContractReads({
        contracts: prizePercentageContracts,
        watch: false
    });

    const [prizePercentage, setPrizePercentage] = useState([0, 0, 0, 0, 0, 0, 0]);

    useEffect(() => {
        setPrizePercentage(rawPrizePercentage.map(item => item.result));
    }, [rawPrizePercentage]);

    const prizeDistributedContracts = [
        {
            ...Web3Game2048ContractData,
            functionName: 'firstPrizeDistributed',
            watch: true,
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'secondPrizeDistributed',
            watch: true,
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'thirdPrizeDistributed',
            watch: true,
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'fourthPrizeDistributed',
            watch: true,
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'fifthPrizeDistributed',
            watch: true,
        },
        {
            ...Web3Game2048ContractData,
            functionName: 'sixthPrizeDistributed',
            watch: true,
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

    const { data: withdrawWinnerPrizeData, isLoading: withdrawWinnerPrizeIsLoading, isSuccess: withdrawWinnerPrizeIsSuccess, write: withdrawWinnerPrize } = useContractWrite({
        ...Web3Game2048ContractData,
        functionName: 'withdrawWinnerPrize',
    });

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
                                                <Tooltip showArrow={true} content={`${prizePercentage[index]}% of Prize Pool`} key="secondary" color="secondary">
                                                    <Image
                                                        shadow="sm"
                                                        width="100%"
                                                        alt={item.title}
                                                        className="w-full object-cover"
                                                        src={item.img}
                                                    />
                                                </Tooltip>
                                            </CardBody>
                                            <CardFooter className="text-small justify-center">
                                                <p>{item.prize}</p>
                                            </CardFooter>
                                        </Card>
                                    ))}
                                </div>
                                <Divider className="my-2" />
                                <div className="flex justify-center align-center flex-col">
                                    <div className="mb-3">
                                        You have <Kbd className="font-semibold">{winnerPrizeBalance + " ETH"}</Kbd> to claim!
                                    </div>
                                    <Button color="success" className="w-28" size="sm" isDisabled={withdrawWinnerPrizeIsLoading || winnerPrizeBalance == 0} onClick={() => withdrawWinnerPrize()}>
                                        {withdrawWinnerPrizeIsLoading ? "Loading..." : "Claim"}
                                    </Button>
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