'use client';

import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react';

import { WagmiConfig, configureChains, createConfig } from 'wagmi';
import { optimism, optimismSepolia } from 'viem/chains';
import { infuraProvider } from 'wagmi/providers/infura';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { jsonRpcProvider } from 'wagmi/providers/jsonRpc'
import { InjectedConnector } from 'wagmi/connectors/injected';
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect';

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = process.env.PROJECT_ID;

const metadata = {
    name: process.env.APP_NAME,
    description: process.env.APP_DESCRIPTION,
    url: process.env.APP_URL,
    icons: [process.env.APP_ICON]
};

// Default Wagmi Config with Public RPC
// const chains = [optimismSepolia];
// const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });
const mantaSepoliaTestnet = {
    "id": 3441006,
    "name": "Manta Pacific Sepolia Testnet",
    "network": "manta-sepolia",
    "nativeCurrency": {
        "decimals": 18,
        "name": "ETH",
        "symbol": "ETH"
    },
    "rpcUrls": {
        "default": {
            "http": [
                "https://pacific-rpc.sepolia-testnet.manta.network/http"
            ]
        }
    },
    "blockExplorers": {
        "default": {
            "name": "Manta Sepolia Testnet Explorer",
            "url": "https://pacific-explorer.sepolia-testnet.manta.network",
            "apiUrl": "https://pacific-explorer.sepolia-testnet.manta.network/api"
        }
    },
    "contracts": {
        "multicall3": {
            "address": "0xca54918f7B525C8df894668846506767412b53E3",
            "blockCreated": 479584
        }
    },
    "testnet": true
};

// Custom Config with Alchemy and Infura RPC
const { chains, publicClient } = configureChains(
    [mantaSepoliaTestnet],
    [
        jsonRpcProvider({
          rpc: (chain) => ({
            http: process.env.ONERPC_MANTA_SEPOLIA_RPC_URL
          }),
        }),
    ],
    // [
    //     alchemyProvider({ apiKey: process.env.ALCHEMY_API_KEY }),
    //     infuraProvider({ apiKey: process.env.INFURA_API_KEY }),
    // ],
);

const wagmiConfig = createConfig({
    autoConnect: true,
    connectors: [
        new InjectedConnector({ chains }),
        new WalletConnectConnector({
            chains: [mantaSepoliaTestnet],
            options: {
              projectId: process.env.PROJECT_ID,
            },
          })
      ],
    publicClient,
    metadata,
})

// 3. Create modal
createWeb3Modal({
    wagmiConfig,
    projectId,
    chains,
    defaultChain: mantaSepoliaTestnet,
    enableAnalytics: true // Optional - defaults to your Cloud configuration
});

export function Web3Modal({ children }) {
    return <WagmiConfig config={wagmiConfig}>{children}</WagmiConfig>
};