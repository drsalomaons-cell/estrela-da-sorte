# Estrela da Sorte - Release checklist

## Implemented in repository
- Ecosystem roles, permissions, approvals and audit
- Events and gift catalog with lucky/unlucky categories
- Room sessions and participants with maximum 30 seats
- Chat and gift event records
- Economy audit and simulation ledger
- 20 slot catalog entries and unified game registry
- Mobile release readiness checklist

## Requires real environment execution
- npm ci && npm run build
- Supabase migrations against a real project
- LiveKit credentials and real room connection
- Android APK/AAB build and device test
- Real slot/game assets and playable integration
- Google Play screenshots and store listing

## Important status rule
Catalog entries are not the same as playable games. The 20 slot entries are integration targets until each game has a tested playable implementation and valid licensing.
