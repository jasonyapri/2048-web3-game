/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    INFURA_API_KEY: process.env.INFURA_API_KEY,
    ALCHEMY_API_KEY: process.env.ALCHEMY_API_KEY,
    APP_NAME: process.env.APP_NAME,
    APP_DESCRIPTION: process.env.APP_DESCRIPTION,
    APP_URL: process.env.APP_URL,
    APP_ICON: process.env.APP_ICON,
    PROJECT_ID: process.env.PROJECT_ID,
    RPC_URL: process.env.RPC_URL,
    ETHERSCAN_URL: process.env.ETHERSCAN_URL,
    QUICKNODE_OPTIMISM_SEPOLIA_RPC_URL: process.env.QUICKNODE_OPTIMISM_SEPOLIA_RPC_URL,
    QUICKNODE_OPTIMISM_SEPOLIA_RPC_WS_URL: process.env.QUICKNODE_OPTIMISM_SEPOLIA_RPC_WS_URL,
    ONERPC_MANTA_SEPOLIA_RPC_URL: process.env.ONERPC_MANTA_SEPOLIA_RPC_URL,
    LISK_SEPOLIA_RPC_URL: process.env.LISK_SEPOLIA_RPC_URL,
    CHAIN_ID: process.env.CHAIN_ID,
  },
    webpack: config => {
        config.externals.push('pino-pretty', 'lokijs', 'encoding')
        return config
      }
};

export default nextConfig;
