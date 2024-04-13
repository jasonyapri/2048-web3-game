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
    RPC_URL: process.env.RPC_URL,
  },
    webpack: config => {
        config.externals.push('pino-pretty', 'lokijs', 'encoding')
        return config
      }
};

export default nextConfig;
