## 1.2.0

- Added email-based lookup — pass `email` instead of `handle` for B2B integrations
- All badge widgets now accept optional `email` parameter
- API client supports `email` query parameter
- Companies can now look up users by email (which they already have) instead of World Credit handles

## 1.1.0

- Added unverified badge state for users without a World Credit account
- Inline: "Not Verified" in muted gray
- Pill: "—" score with "NOT VERIFIED" tag
- Card: "Not Verified" with "GET VERIFIED →" CTA
- Shield: "?" instead of checkmark
- Added `verified` field to BadgeData model
- Unverified badges link to world-credit.com/signup

## 1.0.3

- Moved Package.swift to repo root for proper SPM compatibility
- No code changes — metadata only

## 1.0.1

- Added API key configuration to Quick Start documentation
- API key is required — get yours at world-credit.com

## 1.0.0

- Initial release
- Four badge styles: inline, pill, card, shield
- Dark and light themes
- Three sizes: sm, md, lg
- API key authentication support
- Built-in caching with configurable TTL
- Programmatic data fetching via `WorldCreditBadge.fetch()`
