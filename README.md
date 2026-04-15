# Will I Make It?

> HUFS 학생을 위한 셔틀 의사결정 앱. 시간표가 아니라 "지금 버스 잡을 수 있나"라는 답을 준다.

[![CI](https://github.com/GthingkingG/will-i-make-it/actions/workflows/ci.yml/badge.svg)](https://github.com/GthingkingG/will-i-make-it/actions/workflows/ci.yml)

## What it does

사용자가 강의실에서 셔틀 정류장으로 걸어가는 중에 앱을 열면, 화면 중앙에 숫자 하나가 뜬다.

> **87%** — 평소 걸음 속도면 다음 셔틀 탑승 가능

GPS + 걷는 속도 + 셔틀 스케줄을 조합해 탑승 확률을 계산한다. 실패 시 대안(다음 셔틀 또는 광역버스)을 제시.

카카오맵/네이버지도가 HUFS 교내 셔틀을 인지하지 않는 틈을 메운다.

## Stack

- **Mobile:** Flutter (iOS + Android)
- **Backend:** Supabase (Postgres + pg_cron + Edge Functions)
- **API proxy:** Vercel Edge Functions (경기도 버스정보시스템 API 키 보호)
- **CI/CD:** GitHub Actions + Fastlane match
- **Analytics (v1.0+):** Sentry

## Status

🚧 **v0.1 개발 중.** Apple Developer 계정 승인 대기.

설계 문서: [`docs/DESIGN_v0.md`](./docs/DESIGN_v0.md)

## Roadmap

- **v0.1** — "Will I make it?" 단일 화면. TestFlight Public + Play Internal.
- **v1.0** — 모노레포 리팩터링 + 광역버스 환승 + 디자인 시스템 + 공개 스토어 출시.
- **v1.1+** — 즐겨찾는 정류장, 실측 데이터 기반 정확도 튜닝.
- **v2** — iOS Live Activity + Android Home Widget ("앱 안 여는 앱"), LLM 대화형 플래너.

## Built with

Claude Code + [gstack](https://github.com/garrytan/gstack) (`/office-hours` → `/design-consultation` → `/feature-planner`).

"48시간에 AI 에이전트팀으로 풀스택 모바일 앱 출시" 포트폴리오 케이스 스터디. 이력서 자료로 제작.

## License

MIT
