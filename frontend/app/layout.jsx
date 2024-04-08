import { Inria_Sans } from "next/font/google";
import "./globals.css";
import { Web3Modal } from '@/context/Web3Modal';

const inriaSans = Inria_Sans({ subsets: ["latin"], weight: ["300", "400", "700"] });

export const metadata = {
  title: process.env.APP_NAME,
  description: process.env.APP_DESCRIPTION,
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inriaSans.className}>
        <Web3Modal>{children}</Web3Modal>
      </body>
    </html>
  );
}
