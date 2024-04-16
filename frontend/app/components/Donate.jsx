'use client';

import { React, useEffect, useState, useMemo } from "react";
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, Input, useDisclosure, Tooltip, Kbd, Divider } from "@nextui-org/react";
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import { useContractEvent, useContractRead, useContractReads, useContractWrite } from 'wagmi';
import { ethers } from 'ethers';
import Confetti from 'react-confetti'
import useWindowSize from 'react-use/lib/useWindowSize'
import { toast } from "react-toastify";

const Donate = () => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const DEFAULT_DONATE_AMOUNT = "0.05";

    const [showConfetti, setShowConfetti] = useState(false);
    const { width } = useWindowSize();
    const height = document.documentElement.scrollHeight;

    useContractEvent({
        ...Web3Game2048ContractData,
        eventName: 'DonationToPrizePoolReceived',
        listener(donationLogs) {
            for (let donationLog of donationLogs) {
                setShowConfetti(true);

                toast(`Somebody donated ${ethers.utils.formatEther(donationLog.args.amount)} to the Prize Pool.`);

                setDonateToPrizePoolAmount(DEFAULT_DONATE_AMOUNT);

                setTimeout(() => {
                    setShowConfetti(false);
                }, 10000);
            }
        },
    });

    const [donateToPrizePoolAmount, setDonateToPrizePoolAmount] = useState(DEFAULT_DONATE_AMOUNT);
    const [donateToPrizePoolAmountInWei, setDonateToPrizePoolAmountInWei] = useState();

    const [donatorName, setDonatorName] = useState("");

    useEffect(() => {
        if (donateToPrizePoolAmount) {
            let newAmountInWei = ethers.utils.parseEther(donateToPrizePoolAmount).toString();
            setDonateToPrizePoolAmountInWei(newAmountInWei);
        }
    }, [donateToPrizePoolAmount]);

    const { data: donateToPrizePooleData, isLoading: donateToPrizePoolIsLoading, isSuccess: donateToPrizePoolIsSuccess, write: donateToPrizePool } = useContractWrite({
        ...Web3Game2048ContractData,
        functionName: 'donateToPrizePool',
        value: donateToPrizePoolAmountInWei,
    });

    return (
        <>
            <div className="donate-to-prize-pool">
                <p>Please kindly consider <a className="open-donate-modal-button" onClick={onOpen} >donating to the prize pool</a> to support this project and encourage other people to play this web3 game 🙂</p>
            </div>

            {showConfetti && (
                <Confetti
                    width={width}
                    height={height}
                />
            )}

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
                            <ModalHeader className="flex flex-col gap-1">Donate</ModalHeader>
                            <ModalBody>
                                <h2>Set Your Name</h2>
                                <Input
                                    type="text"
                                    variant="bordered"
                                    color="default"
                                    className="max-w-xs"
                                    placeholder="Jason Yapri"
                                    value={donatorName}
                                    onValueChange={setDonatorName}
                                    startContent={
                                        <div className="pointer-events-none flex items-center">
                                            <span className="text-default-400 text-small">Name</span>
                                        </div>
                                    }
                                />
                                <h2>Donate to Prize Pool</h2>
                                <Input
                                    type="number"
                                    variant="bordered"
                                    color="default"
                                    placeholder="0.05"
                                    step="0.01"
                                    min={0.001}
                                    value={donateToPrizePoolAmount}
                                    onValueChange={setDonateToPrizePoolAmount}
                                    className="max-w-xs"
                                    endContent={
                                        <div className="pointer-events-none flex items-center">
                                            <span className="text-default-400 text-small">ETH</span>
                                        </div>
                                    }
                                />
                                <Button color="success" className="w-28" size="sm" isDisabled={donateToPrizePoolIsLoading} onClick={() => donateToPrizePool()}>
                                    {donateToPrizePoolIsLoading ? "Loading..." : "Donate"}
                                </Button>
                                <Divider />
                                {/* <h2>Donate to Author</h2> */}

                            </ModalBody>
                            <ModalFooter />
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    );
};

export default Donate;