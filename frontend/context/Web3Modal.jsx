'use client'

import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react';

import { WagmiConfig } from 'wagmi';
import { optimism, optimismSepolia } from 'viem/chains';

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = process.env.NEXT_PUBLIC_PROJECT_ID;

// 2. Create wagmiConfig
const metadata = {
    name: process.env.APP_NAME,
    description: process.env.APP_DESCRIPTION,
    url: process.env.APP_URL,
    icons: [process.env.APP_ICON]
};

const chains = [optimismSepolia];
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });

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