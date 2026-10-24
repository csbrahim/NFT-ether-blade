import type { Metadata } from 'next';
import './globals.css';
import { Web3Provider } from '@/components/Web3Provider';

export const metadata: Metadata = {
  title: 'Ether-Blade | Dynamic On-Chain NFT',
  description: '100% On-Chain SVG GameFi NFT with dynamic stats and leveling',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-black text-white antialiased">
        <Web3Provider>{children}</Web3Provider>
      </body>
    </html>
  );
}