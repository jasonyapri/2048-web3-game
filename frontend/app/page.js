import Image from "next/image";

export default function Home() {
  return (
    <div className="game-container">
      <header className="wallet-header">
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
        <div className="game-header">
          <div className="title-group">
            <div className="subtitle">Web3 Game</div>
            <img src="/img/title.png" className="title-logo" />
          </div>
          <div className="game-info">
            <div className="move-count">
              <span className="move-count-title">MOVE COUNT</span>
              <div className="move-count-number">2</div>
            </div>
            <div className="prize-pool">
              <span className="prize-pool-title">PRIZE POOL</span>
              <div className="prize-pool-amount">0.001 ETH</div>
            </div>
          </div>
        </div>
        <div className="game-board">
          {/* Game tiles would be dynamically generated here */}
        </div>
        <div className="game-instructions">
          <p>Join the tiles, get to <span className="title">2048</span>!</p>
        </div>
        <footer className="game-footer">
          Created by <a href="https://jasonyapri.com" className="author" target="_blank">Jason Yapri</a>. Proudly made in <a href="https://www.google.com/search?q=indonesia" className="indonesia" target="_blank">Indonesia</a>.
        </footer>
      </main>
    </div>
  );
}
