const moveHistoryDummyData = [
    {
        address: '0x123',
        move: 0
    },
    {
        address: '0x',
        move: 2
    }
];

const Move = {
    0: 'UP',
    1: 'DOWN',
    2: 'LEFT',
    3: 'RIGHT'
};

const printMove = (move) => {
    return Move[move];
};

const moveHistoryColumns = [
    {
        accessorKey: 'address',
        header: 'Address',
        cell: (props) => <p>{props.getValue()}</p>
    },
    {
        accessorKey: 'move',
        header: 'Move',
        cell: (props) => <p>{printMove(props.getValue())}</p>
    },
];

export { moveHistoryDummyData, moveHistoryColumns };