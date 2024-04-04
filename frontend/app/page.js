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
          <div className="row-1">
            <div className="tile tile-0-0">2</div>
            <div className="tile tile-0-1">4</div>
            <div className="tile tile-0-2">8</div>
            <div className="tile tile-0-3">16</div>
          </div>
        </div>
        <div className="game-buttons">
          <button className="game-button left">
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
        <div className="game-instruction">
          <p>Join the tiles, get to <span className="title">2048</span>!</p>
        </div>
        <div className="line"></div>
        <div className="game-instruction">
          <p><span className="highlighted">HOW TO PLAY:</span> Use the arrow buttons above to move the tiles. Tiles with the same number merge into one when they touch. Add them up to reach 2048!</p>
        </div>
        <div className="line"></div>
        <div className="game-instruction">
          <p>You’re playing the web3 version of 2048 where the board is shared among all players worldwide. Everyone have the chance to win ETH from the Prize Pool once you reach a certain number for the first time!</p>
          <span>See <a href="#" className="list-prizes-button">List of Prizes</a>.</span>
        </div>
        <div className="line"></div>
        <footer className="game-footer">
          Created by <a href="https://jasonyapri.com" className="author" target="_blank">Jason Yapri</a>. Proudly made in <a href="https://www.google.com/search?q=indonesia" className="indonesia" target="_blank">Indonesia</a>.
        </footer>
      </main>
    </div>
  );
}
