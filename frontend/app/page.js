import Image from "next/image";

export default function Home() {
  return (
    <div className="game-container">
      <header className="game-header bg-theme-red flex items-center justify-center h-20 border-b-1">
        <div className="wallet-balance">Wallet Balance: 0.35 ETH</div>
        <button className="connect-wallet-button">CONNECT WALLET</button>
      </header>
      <main className="game-main">
        <div className="title">2048</div>
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
