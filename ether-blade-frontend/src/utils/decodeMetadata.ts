export interface Attribute {
  trait_type: string;
  value: string | number;
}

export interface EtherBladeMetadata {
  name: string;
  description: string;
  image: string;
  attributes: Attribute[];
}

export function decodeTokenURI(tokenURI: string): EtherBladeMetadata | null {
  try {
    if (!tokenURI || !tokenURI.startsWith("data:application/json;base64,")) {
      return null;
    }
    const base64Data = tokenURI.replace("data:application/json;base64,", "");
    const jsonString =
      typeof window !== "undefined"
        ? window.atob(base64Data)
        : Buffer.from(base64Data, "base64").toString("utf-8");

    return JSON.parse(jsonString) as EtherBladeMetadata;
  } catch (error) {
    console.error("Failed to decode tokenURI:", error);
    return null;
  }
}