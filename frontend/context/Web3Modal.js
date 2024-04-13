'use client';

import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react';

import { WagmiConfig, configureChains, createConfig } from 'wagmi';
import { optimism, optimismSepolia, chain } from 'viem/chains';
import { infuraProvider } from 'wagmi/providers/infura';
import { alchemyProvider } from 'wagmi/providers/alchemy';

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

// Custom Config with Alchemy and Infura RPC
const { chains, publicClient } = configureChains(
    [optimismSepolia],
    [
        alchemyProvider({ apiKey: process.env.ALCHEMY_API_KEY }),
        // infuraProvider({ apiKey: process.env.INFURA_API_KEY }),
    ],
);

const wagmiConfig = createConfig({
    autoConnect: true,
    publicClient,
    metadata,
})

// 3. Create modal
createWeb3Modal({
    wagmiConfig,
    projectId,
    chains,
    defaultChain: optimismSepolia,
    enableAnalytics: true // Optional - defaults to your Cloud configuration
});

export function Web3Modal({ children }) {
    return <WagmiConfig config={wagmiConfig}>{children}</WagmiConfig>
};