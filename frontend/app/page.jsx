"use client";

import Image from "next/image";
import { React, useEffect, useState } from 'react';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Web3Game2048ContractData from '@/contracts/Web3Game2048ContractData';
import { useWeb3Modal } from '@web3modal/wagmi/react';
import { useAccount, useContractRead, useContractWrite, useContractReads, useContractEvent } from 'wagmi';
import MoveCount from './components/MoveCount';
import PrizePool from './components/PrizePool';
import Donate from './components/Donate';
import { ethers } from 'ethers';
import useWindowSize from 'react-use/lib/useWindowSize'
import { useNetwork, useSwitchNetwork } from 'wagmi'

export default function Home() {

  const MAKE_MOVE_GAS_LIMIT = 200000n;

  // const { open } = useWeb3Modal();
  const { address, isConnected, isConnecting, isDisconnected } = useAccount();
  const width = (typeof window !== 'undefined') ? useWindowSize().width : 100;
  const height = (typeof window !== 'undefined') ? document.documentElement.scrollHeight : 100;

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

  const targetChainId = process.env.CHAIN_ID;
  const { chain } = useNetwork()
  const { switchNetwork } = useSwitchNetwork({
    chainId: targetChainId,
  })

  useEffect(() => {
    if (chain?.id !== targetChainId) {
      switchNetwork?.(targetChainId)
    }
  }, [chain, switchNetwork, targetChainId])

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
    watch: true
  });

  const [openPrizeModal, setOpenPrizeModal] = useState(false);

  const [actionIsAllowed, setActionIsAllowed] = useState(false);

  useEffect(() => {
    setActionIsAllowed(isConnected);
  }, [isConnected]);

  useEffect(() => {
    if (rawGameBoardData) {
      const cleanGameBoardTiles = rawGameBoardData.map(item => item.result);
      setGameBoardTiles(cleanGameBoardTiles);
    }
  }, [rawGameBoardData]);

  const { data: makeMoveUpData, isLoading: makeMoveUpIsLoading, isSuccess: makeMoveUpIsSuccess, write: makeMoveUp } = useContractWrite({
    ...Web3Game2048ContractData,
    functionName: 'makeMove',
    args: [0],
    gas: MAKE_MOVE_GAS_LIMIT,
    onSettled(data, error) {
      if (error) {
        if (error.message.includes('NoValidMoveMade')) {
          toast.error("Up is not a valid move. Try another direction~");
        }
      }
    },
  });

  const { data: makeMoveDownData, isLoading: makeMoveDownIsLoading, isSuccess: makeMoveDownIsSuccess, write: makeMoveDown } = useContractWrite({
    ...Web3Game2048ContractData,
    functionName: 'makeMove',
    args: [1],
    gas: MAKE_MOVE_GAS_LIMIT,
    onSettled(data, error) {
      if (error) {
        if (error.message.includes('NoValidMoveMade')) {
          toast.error("Down is not a valid move. Try another direction~");
        }
      }
    },
  });

  const { data: makeMoveLeftData, isLoading: makeMoveLeftIsLoading, isSuccess: makeMoveLeftIsSuccess, write: makeMoveLeft } = useContractWrite({
    ...Web3Game2048ContractData,
    functionName: 'makeMove',
    args: [2],
    gas: MAKE_MOVE_GAS_LIMIT,
    onSettled(data, error) {
      if (error) {
        if (error.message.includes('NoValidMoveMade')) {
          toast.error("Left is not a valid move. Try another direction~");
        }
      }
    },
  });

  const { data: makeMoveRightData, isLoading: makeMoveRightIsLoading, isSuccess: makeMoveRightIsSuccess, write: makeMoveRight } = useContractWrite({
    ...Web3Game2048ContractData,
    functionName: 'makeMove',
    args: [3],
    gas: MAKE_MOVE_GAS_LIMIT,
    onSettled(data, error) {
      if (error) {
        if (error.message.includes('NoValidMoveMade')) {
          toast.error("Right is not a valid move. Try another direction~");
        }
      }
    },
  });

  const [prizePoolInEth, setPrizePoolInEth] = useState(0);
  const [moveCount, setMoveCount] = useState(0);

  useEffect(() => {
    if (rawPrizePool) {
      const prizePoolInWei = ethers.BigNumber.from(rawPrizePool);
      setPrizePoolInEth(parseFloat(ethers.utils.formatEther(prizePoolInWei)).toFixed(6));
    }
  }, [rawPrizePool]);

  useEffect(() => {
    if (rawMoveCount) {
      setMoveCount(rawMoveCount);
    }
  }, [rawMoveCount]);

  const backgroundStyle = {
    0: '',
    2: 'linear-gradient(to bottom left,  #FFF1D0, #99917D)',
    4: 'linear-gradient(to bottom left,  #E9EBF8, #898A92)',
    8: 'linear-gradient(to bottom left,  #A5F8D3, #61927C)',
    16: 'linear-gradient(to bottom left,  #FFB997, #996F5B)',
    32: 'linear-gradient(to bottom left,  #F06543, #8A3A27)',
    64: 'linear-gradient(to bottom left,  #BD320F, #571707)',
    128: 'linear-gradient(to bottom left,  #95B8D1, #4C5E6B)',
    256: 'linear-gradient(to bottom left,  #2B2D42, #6D73A8)',
    512: 'linear-gradient(to bottom left,  #977390, #31252F)',
    1024: 'linear-gradient(to bottom left,  #A54657, #3F1B21)',
    2048: 'linear-gradient(to bottom left,  #FDC801, #977701)',
  };

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
            <MoveCount moveCount={moveCount} address={address} width={width} height={height} />
            <PrizePool prizePoolInEth={prizePoolInEth} address={address} openPrizeModal={openPrizeModal} setOpenPrizeModal={setOpenPrizeModal} width={width} height={height} ></PrizePool>
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
                    <div className={`tile tile-${rowIndex}-${colIndex} tile-${gameBoardTiles ? (gameBoardTiles[(rowIndex * 4) + colIndex]) : ""} flex justify-center items-center`} key={`${rowIndex}-${colIndex}`} style={{ background: backgroundStyle[gameBoardTiles ? (gameBoardTiles[(rowIndex * 4) + colIndex]) : "0"] }}></div>
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
        <div className="game-actions">
          <div className="game-buttons">
            <button className="game-button left" disabled={!actionIsAllowed || makeMoveLeftIsLoading || makeMoveUpIsLoading || makeMoveDownIsLoading || makeMoveRightIsLoading} onClick={() => makeMoveLeft()}>
              <img src="/img/left-arrow.png" className="game-button-icon" />
            </button>
            <button className="game-button up" disabled={!actionIsAllowed || makeMoveLeftIsLoading || makeMoveUpIsLoading || makeMoveDownIsLoading || makeMoveRightIsLoading} onClick={() => makeMoveUp()}>
              <img src="/img/up-arrow.png" className="game-button-icon" />
            </button>
            <button className="game-button down" disabled={!actionIsAllowed || makeMoveLeftIsLoading || makeMoveUpIsLoading || makeMoveDownIsLoading || makeMoveRightIsLoading} onClick={() => makeMoveDown()}>
              <img src="/img/down-arrow.png" className="game-button-icon" />
            </button>
            <button className="game-button right" disabled={!actionIsAllowed || makeMoveLeftIsLoading || makeMoveUpIsLoading || makeMoveDownIsLoading || makeMoveRightIsLoading} onClick={() => makeMoveRight()}>
              <img src="/img/right-arrow.png" className="game-button-icon" />
            </button>
          </div>
          <div className={`game-buttons-loading${(makeMoveLeftIsLoading || makeMoveUpIsLoading || makeMoveDownIsLoading || makeMoveRightIsLoading) ? "" : " hide"}`}>Loading Web3 Wallet...</div>
          <div className={`game-buttons-loading${(!actionIsAllowed) ? "" : " hide"}`}>Please connect to your Web3 Wallet of choice...</div>
        </div>
        <div className="game-instructions instruction-2">
          <p><span className="highlighted">HOW TO PLAY:</span> Use the arrow buttons above to move the tiles. Tiles with the same number merge into one when they touch. Add them up to reach 2048!</p>
        </div>
        <div className="line"></div>
        <div className="game-instructions instruction-3">
          <p>You’re playing the web3 version of 2048 where the board is shared among all players worldwide. Everyone have the chance to win ETH from the Prize Pool once you reach a certain number for the first time!</p>
          <span>See <a style={{ cursor: "pointer" }} onClick={() => setOpenPrizeModal(true)} className="list-prizes-button">List of Prizes</a>.</span>
        </div>
        <div className="line"></div>
        <Donate address={address} width={width} height={height} />
        <div className="line"></div>
        <footer className="game-footer">
          Created by <a href="https://jasonyapri.com" className="author" target="_blank">Jason Yapri</a>. Proudly made in <a href="https://www.google.com/search?q=indonesia" className="indonesia" target="_blank">Indonesia</a>.
        </footer>
      </main >
    </div >
  );
}
