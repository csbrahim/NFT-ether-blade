"use client";

import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ETHER_BLADE_ADDRESS, ETHER_BLADE_ABI } from '@/config/contract';
import { BladeCard } from '@/components/BladeCard';

export default function Home() {
  const { isConnected } = useAccount();

  // Fetch total minted count from contract
  const { data: rawTokenCounter, refetch: refetchTokenCounter } = useReadContract({
    address: ETHER_BLADE_ADDRESS as `0x${string}`,
    abi: ETHER_BLADE_ABI,
    functionName: 'getTokenCounter',
  });

  // Mint transaction hook
  const { writeContract, data: txHash, isPending: isSigning, error: writeError } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({ hash: txHash });

  // Generate array of token IDs up to tokenCounter (IDs are 0-indexed)
  const totalMinted = typeof rawTokenCounter === 'bigint' ? Number(rawTokenCounter) : 0;
  const tokenIds = Array.from({ length: totalMinted }, (_, i) => BigInt(i));

  const handleMint = () => {
    writeContract({
      address: ETHER_BLADE_ADDRESS as `0x${string}`,
      abi: ETHER_BLADE_ABI,
      functionName: 'mintBlade',
    }, {
      onSuccess: () => {
        refetchTokenCounter();
      }
    });
  };

  return (
    <main className="min-h-screen bg-black text-white p-8">
      <nav className="flex justify-between items-center mb-12 border-b border-gray-800 pb-6">
        <h1 className="text-3xl font-black italic tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-600">
          ETHER-BLADE
        </h1>
        <ConnectButton />
      </nav>

      {!isConnected ? (
        <div className="text-center py-20">
          <h2 className="text-5xl font-bold mb-4">Forge Your Legacy.</h2>
          <p className="text-gray-400 mb-8">Connect your wallet to mint 100% on-chain dynamic SVG NFTs.</p>
        </div>
      ) : (
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4 mb-8">
            <div>
              <h2 className="text-3xl font-extrabold">Your Armory</h2>
              <p className="text-gray-400 mt-1">
                Total Blades Minted: <span className="text-purple-400 font-bold">{totalMinted}</span>
              </p>
            </div>

            <button
              onClick={handleMint}
              disabled={isSigning || isConfirming}
              className="px-8 py-4 bg-gradient-to-r from-purple-500 to-pink-600 text-white font-black rounded-full hover:opacity-90 transition-transform active:scale-95 disabled:opacity-50"
            >
              {isSigning ? "Signing..." : isConfirming ? "Minting..." : "MINT BLADE (FREE)"}
            </button>
          </div>

          {writeError && (
            <div className="mb-6 p-4 bg-red-900/40 border border-red-500/50 text-red-300 rounded-xl text-center text-sm">
              Transaction Error: {writeError.message.slice(0, 150)}
            </div>
          )}

          {isConfirmed && (
            <div className="mb-6 p-4 bg-green-900/40 border border-green-500/50 text-green-300 rounded-xl text-center">
              🎉 Blade successfully minted! Card generated on-chain below.
            </div>
          )}

          {tokenIds.length === 0 ? (
            <div className="text-center py-16 border border-dashed border-gray-800 rounded-2xl">
              <p className="text-gray-500 mb-4">No Blades in your armory yet.</p>
              <p className="text-sm text-gray-600">Click the button above to mint Token #0!</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
              {tokenIds.map((id) => (
                <BladeCard key={id.toString()} tokenId={id} />
              ))}
            </div>
          )}
        </div>
      )}
    </main>
  );
}
