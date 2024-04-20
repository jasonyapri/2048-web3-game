import { Inria_Sans } from "next/font/google";
import "./globals.css";
import { Web3Modal } from '@/context/Web3Modal';
import { Providers } from "./providers";
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

const inriaSans = Inria_Sans({ subsets: ["latin"], weight: ["300", "400", "700"] });

export const metadata = {
  title: process.env.APP_NAME,
  description: process.env.APP_DESCRIPTION,
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inriaSans.className}>
        <Providers>
          <Web3Modal>{children}</Web3Modal>
        </Providers>
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
