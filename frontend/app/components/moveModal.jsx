import { useState } from 'react';

const MoveModal = ({ moveCount }) => {
    const [isOpen, setIsOpen] = useState(false);

    const openModal = () => {
        setIsOpen(true);
    };

    const closeModal = () => {
        setIsOpen(false);
    };

    const stopPropagation = (e) => {
        e.stopPropagation();
    };

    return (
        <>
            <button className="move-count" onClick={openModal}>
                <span className="move-count-title">MOVE COUNT</span>
                <div className="move-count-number">{moveCount.toString()}</div>
            </button>

            {isOpen && (
                <div onClick={closeModal} className="move-count-modal-area fixed top-0 left-0 w-full h-full bg-black bg-opacity-50 flex items-center justify-center z-50 m-0">
                    <div onClick={stopPropagation} className="bg-white p-4 rounded-lg shadow-lg">
                        <h2 className="text-2xl font-semibold mb-4 text-black">Moves History</h2>
                        <p className="mb-4 text-black">This is a full-screen modal example using Tailwind CSS.</p>
                        <button onClick={closeModal} className="px-4 py-2 bg-red-500 text-white rounded">
                            Close Modal
                        </button>
                    </div>
                </div>
            )}
        </>
    );
};

export default MoveModal;