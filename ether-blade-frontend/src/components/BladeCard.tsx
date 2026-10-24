"use client";

import React, { useMemo, useEffect } from 'react';
import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ETHER_BLADE_ADDRESS, ETHER_BLADE_ABI } from '@/config/contract';
import { decodeTokenURI, EtherBladeMetadata, Attribute } from '@/utils/decodeMetadata';
import { Sword, TrendingUp, Star } from 'lucide-react';

export function BladeCard({ tokenId }: { tokenId: bigint }) {
  const { data: rawTokenURI, isError, refetch } = useReadContract({
    address: ETHER_BLADE_ADDRESS as `0x${string}`,
    abi: ETHER_BLADE_ABI,
    functionName: 'tokenURI',
    args: [tokenId],
  });

  const { writeContract, data: hash, isPending: isSigning } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({ hash });

  // Derive metadata directly from contract output (No setMetadata needed!)
  const metadata: EtherBladeMetadata | null = useMemo(() => {
    if (typeof rawTokenURI === 'string') {
      return decodeTokenURI(rawTokenURI);
    }
    return null;
  }, [rawTokenURI]);

  useEffect(() => {
    if (isConfirmed) {
      refetch();
    }
  }, [isConfirmed, refetch]);

  if (isError) {
    return (
      <div className="bg-gray-900 border border-red-500/30 p-6 rounded-2xl text-center text-red-400">
        Token #{tokenId.toString()} metadata unreadable.
      </div>
    );
  }

  if (!metadata) {
    return (
      <div className="animate-pulse bg-gray-900 border border-gray-800 p-6 rounded-2xl h-96 flex items-center justify-center text-gray-500">
        Loading Blade #{tokenId.toString()}...
      </div>
    );
  }

  return (
    <div className="bg-gray-900 border border-purple-500/30 p-6 rounded-2xl shadow-2xl shadow-purple-500/10 hover:border-purple-500/60 transition-all">
      <div className="rounded-lg overflow-hidden border border-gray-700 bg-black mb-4">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={metadata.image} alt={metadata.name} className="w-full h-auto object-contain" />
      </div>

      <h3 className="text-xl font-bold text-white mb-3">{metadata.name}</h3>

      <div className="grid grid-cols-2 gap-3 mb-6">
        {metadata.attributes?.map((attr: Attribute, i: number) => (
          <div key={i} className="bg-gray-800/80 p-2.5 rounded-lg flex items-center gap-2">
            {attr.trait_type === 'Rank' && <Star size={16} className="text-yellow-400" />}
            {attr.trait_type === 'Level' && <TrendingUp size={16} className="text-blue-400" />}
            {attr.trait_type === 'Attack Power' && <Sword size={16} className="text-red-400" />}
            <span className="text-xs text-gray-400">{attr.trait_type}:</span>
            <span className="text-sm font-bold text-white">{attr.value}</span>
          </div>
        ))}
      </div>

      <button
        onClick={() =>
          writeContract({
            address: ETHER_BLADE_ADDRESS as `0x${string}`,
            abi: ETHER_BLADE_ABI,
            functionName: 'trainBlade',
            args: [tokenId],
          })
        }
        disabled={isSigning || isConfirming}
        className="w-full py-3 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white font-bold rounded-xl transition-all active:scale-95 disabled:opacity-50"
      >
        {isSigning ? "Signing..." : isConfirming ? "Training..." : "Train Blade ⚔️"}
      </button>
    </div>
  );
}
