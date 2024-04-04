import Image from "next/image";

export default function Home() {
  return (
    <div className="game-container">
      <header className="game-header">
        <div className="wallet-balance">
          <span className="wallet-balance-title">WALLET BALANCE</span>
          <div className="wallet-balance-amount">0.35 ETH</div>
        </div>
        <button className="connect-wallet-button">
          <img src="/img/wallet.png" className="wallet-logo" />
          <span>CONNECT WALLET</span>
        </button>
        <img src="/img/optimism.png" className="optimism-logo" />
      </header>
      <main className="game-main">
        <div className="title-group">
          <div className="subtitle">Web3 Game</div>
          <div className="title">2048</div>
        </div>
        <div className="game-info">
          <div className="move-count">Move Count: 2</div>
          <div className="prize-pool">Prize Pool: 0.001 ETH</div>
        </div>
        <div className="game-board">
          {/* Game tiles would be dynamically generated here */}
        </div>
        <div className="game-instructions">
          <p>Join the tiles, get to 2048!</p>
        </div>
      </main>
      <footer className="game-footer">
        Created by Jason Yapri. Proudly made in Indonesia.
      </footer>
    </div>
  );
}
