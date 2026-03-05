interface WorldCreditConfig {
  apiKey?: string;
}

interface WorldCreditBadgeData {
  ok: boolean;
  handle: string;
  displayName: string;
  worldScore: number;
  tier: string;
  tierColor: string;
  photoUrl?: string;
  linkedNetworks: string[];
  profileUrl: string;
  categories: Array<{ label: string; score: number }>;
}

interface WorldCreditSDK extends WorldCreditConfig {
  render(element: HTMLElement): void;
  renderAll(): void;
  fetch(handle: string): Promise<WorldCreditBadgeData>;
}

declare global {
  interface Window {
    WorldCredit: WorldCreditSDK;
  }
}

export {};
