import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure, Tooltip, Kbd, Divider } from "@nextui-org/react";

const Donate = () => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();
    return (
        <>
            <div className="donate-to-prize-pool">
                <p>Please kindly consider <a className="open-donate-modal-button" onClick={onOpen} >donating to the prize pool</a> to support this project and encourage other people to play this web3 game 🙂</p>
            </div>

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
                                ...
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