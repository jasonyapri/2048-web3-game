"use client";

import Image from "next/image";
import { React, useEffect, useState } from 'react';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import { useWeb3Modal } from '@web3modal/wagmi/react';
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite, useContractReads } from 'wagmi';
const ethers = require('ethers');

export default function Home() {

  const notify = () => {
    toast("Default Message!");
    // toast.success("Success Message!");
    // toast.info("Info Message!");
    // toast.error("Error Message!");
    // toast.warning("Warning Message!");
  };

  // const { open } = useWeb3Modal();
  const { address, isConnecting, isDisconnected } = useAccount();

  const { data: authorName, isError: fetchAuthorNameIsError, isLoading: fetchAuthorNameIsLoading } = useContractRead({
    ...Web3Game2048ContractData,
    functionName: 'AUTHOR_NAME',
  });

  const { data: rawPrizePool, isError: fetchPrizePoolIsError, isLoading: fetchPrizePoolIsLoading } = useContractRead({
    ...Web3Game2048ContractData,
    functionName: 'prizePool',
    watch: true
  });

  const { data: rawMoveCount, isError: fetchMoveCountIsError, isLoading: fetchMoveCountIsLoading } = useContractRead({
    ...Web3Game2048ContractData,
    functionName: 'moveCount',
    watch: true
  });

  const { data: rawTile00Pool, isError: frawTile00IsError, isLoading: rawTile00IsLoading } = useContractRead({
    ...Web3Game2048ContractData,
    functionName: 'getGameBoardTile',
    args: [0, 0],
    watch: true
  });

  const [gameBoardTiles, setGameBoardTiles] = useState(null);

  const gameBoardTileContracts = [];
  for (let row = 0; row < 4; row++) {
    for (let col = 0; col < 4; col++) {
      gameBoardTileContracts.push({
        ...Web3Game2048ContractData,
        functionName: 'getGameBoardTile',
        args: [row, col],
      });
    }
  }

  const { data: rawGameBoardData, isError: gameBoardIsError, isLoading: gameBoardIsLoading } = useContractReads({
    contracts: gameBoardTileContracts,
  });

  useEffect(() => {
    if (rawGameBoardData) {
      const cleanGameBoardTiles = rawGameBoardData.map(item => item.result);
      setGameBoardTiles(cleanGameBoardTiles);
      console.log(cleanGameBoardTiles);
    }
  }, [rawGameBoardData]);

  const { data, isLoading, isSuccess, write } = useContractWrite({
    ...Web3Game2048ContractData,
    functionName: 'makeMove',
    args: [3]
  });

  const [prizePoolInEth, setPrizePoolInEth] = useState(0);
  const [moveCount, setMoveCount] = useState(0);

  useEffect(() => {
    const prizePoolInWei = ethers.BigNumber.from(rawPrizePool);
    setPrizePoolInEth(ethers.utils.formatEther(prizePoolInWei));
  }, rawPrizePool);

  useEffect(() => {
    setMoveCount(rawMoveCount);
  }, rawMoveCount);

  return (
    <div className="game-container">
      <ToastContainer />
      <header className="wallet-header">
        {/* <w3m-button /> */}
        <w3m-account-button />
        {/* <w3m-connect-button /> */}
        <w3m-network-button />
        {/* <div className="wallet-balance">
          <span className="wallet-balance-title">WALLET BALANCE</span>
          <div className="wallet-balance-amount">0.35 ETH</div>
        </div>
        <button className="connect-wallet-button" onClick={open}>
          <img src="/img/wallet.png" className="wallet-logo" />
          <span>CONNECT WALLET</span>
        </button> */}
        <img src="/img/optimism.png" className="optimism-logo" />
      </header>
      <main className="game-main">
        <div className="game-header">
          <div className="title-group">
            <div className="subtitle">Web3 Game</div>
            <img src="/img/title.png" className="title-logo" />
          </div>
          <div className="game-info">
            <div className="move-count">
              <span className="move-count-title">MOVE COUNT</span>
              <div className="move-count-number">{moveCount.toString()}</div>
            </div>
            <div className="prize-pool">
              <span className="prize-pool-title">PRIZE POOL</span>
              <div className="prize-pool-amount">{prizePoolInEth.toString()} ETH</div>
            </div>
          </div>
        </div>
        <div className="game-instructions instruction-1">
          <p>Join the tiles, get to <span className="title">2048</span>!</p>
        </div>
        <div className="game-board">
          {
            Array.from({ length: 4 }, (_, rowIndex) => (
              <div className={`row row-${rowIndex}`} key={rowIndex}>
                {
                  Array.from({ length: 4 }, (_, colIndex) => (
                    <div className={`tile tile-${rowIndex}-${colIndex} tile-${gameBoardTiles ? (gameBoardTiles[(rowIndex * 4) + colIndex]) : ""}`} key={`${rowIndex}-${colIndex}`}></div>
                  ))
                }
              </div>
            ))
          }
          {/* Placeholder Board
          <div className="row row-0">
            <div className="tile tile-0-0"></div>
            <div className="tile tile-0-1"></div>
            <div className="tile tile-0-2"></div>
            <div className="tile tile-0-3"></div>
          </div>
          <div className="row row-1">
            <div className="tile tile-1-0"></div>
            <div className="tile tile-1-1 tile-2"></div>
            <div className="tile tile-1-2 tile-4"></div>
            <div className="tile tile-1-3 tile-8"></div>
          </div>
          <div className="row row-2">
            <div className="tile tile-2-0 tile-16"></div>
            <div className="tile tile-2-1 tile-32"></div>
            <div className="tile tile-2-2 tile-64"></div>
            <div className="tile tile-2-3 tile-128"></div>
          </div>
          <div className="row row-3">
            <div className="tile tile-3-0 tile-256"></div>
            <div className="tile tile-3-1 tile-512"></div>
            <div className="tile tile-3-2 tile-1024"></div>
            <div className="tile tile-3-3 tile-2048"></div>
          </div> */}
        </div>
        <div className="game-buttons">
          <button className="game-button left" disabled={isLoading} onClick={() => write()}>
            <img src="/img/left-arrow.png" className="game-button-icon" />
          </button>
          <button className="game-button up">
            <img src="/img/up-arrow.png" className="game-button-icon" />
          </button>
          <button className="game-button down">
            <img src="/img/down-arrow.png" className="game-button-icon" />
          </button>
          <button className="game-button right">
            <img src="/img/right-arrow.png" className="game-button-icon" />
          </button>
        </div>
        <div className="game-instructions instruction-2">
          <p><span className="highlighted">HOW TO PLAY:</span> Use the arrow buttons above to move the tiles. Tiles with the same number merge into one when they touch. Add them up to reach 2048!</p>
        </div>
        <div className="line"></div>
        <div className="game-instructions instruction-3">
          <p>You’re playing the web3 version of 2048 where the board is shared among all players worldwide. Everyone have the chance to win ETH from the Prize Pool once you reach a certain number for the first time!</p>
          <span>See <a href="#" className="list-prizes-button">List of Prizes</a>.</span>
        </div>
        <div className="line"></div>
        <footer className="game-footer">
          Created by <a href="https://jasonyapri.com" className="author" target="_blank">Jason Yapri</a>. Proudly made in <a href="https://www.google.com/search?q=indonesia" className="indonesia" target="_blank">Indonesia</a>.
        </footer>
      </main >
    </div >
  );
}
