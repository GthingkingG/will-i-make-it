# Session Context

## 🎯 Current Work
- **Plans to execute**: `docs/plans/ui-v0.1-plan.md` + `docs/plans/ci-v0.1-plan.md`
- **Phase**: Phase 2 (Wave 1 dispatch) — **권한 실패 2회, 재시작 필요**
- **Branch**: `main` (워크트리 클린)

## 📍 Now
**다음 세션은 반드시 `claude --dangerously-skip-permissions`로 시작.** 일반 모드에서는 서브에이전트가 mutating Bash를 못 씀.

## 📋 Todo (다음 세션, 순서대로)
- [ ] `claude --dangerously-skip-permissions`로 새 터미널에서 실행 확인
- [ ] **단일 메시지**에 Agent 호출 2개 — UI + CI (`isolation: "worktree"`, `mode: "bypassPermissions"`)
- [ ] 에이전트 진행 모니터링 + 블로커 즉시 대응
- [ ] PR 들어오면 `gstack:review` → 사용자 머지 → `superpowers:finishing-a-development-branch`

## 🧠 Lesson Learned (오늘의 핵심)
- `.claude/settings.json`의 `permissions.allow`가 **백그라운드 서브에이전트에 전파 안 됨** — interactive 부모 세션에서는 allow 룰 무효
- `mode: "bypassPermissions"` Agent 파라미터, `dangerouslyDisableSandbox: true` 모두 무효
- **유일한 작동 경로**: 부모 세션 자체가 `--dangerously-skip-permissions`로 시작
- 안전망: 워크트리 물리 격리 + settings.json deny 룰(`gh pr merge`, `--force`, `--no-verify`, `rm -rf /` 등) 유지
- 이 실패 → 회고 문서화하면 포트폴리오 내러티브 보강

## ⚠️ Watch Out
- Phase 2는 **2-6시간 활성 세션 필요**
- 서브에이전트가 PR 생성 시 머지는 **사용자 권한** — `gh pr merge`는 deny 룰로도 차단됨
- pubspec.yaml 충돌 룰: UI 우선권. CI는 UI PR 머지 후 rebase
- 외부 블로커: Apple 승인 대기 / Google Play 미가입 / Supabase 미생성 (v0.1엔 불필요)

## 🚫 Blockers (해소 조건)
- 권한 모드 → 새 세션을 `--dangerously-skip-permissions`로 시작하면 해소

## 🔧 Env
- `~/.zshrc` 자동 로드: `PATH`(pub-cache, android sdk, jbr), `ANDROID_HOME`, `JAVA_HOME`
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## 📌 Recent commits
- `e5de198` [Chore] settings.json 권한 룰 (allow/deny) — allow는 무효 확인됨, deny는 유효
- `3832907` [Chore] CHANGELOG 동기화
- `4933e6a` [Chore] SESSION.md 자동 덮어쓰기 제거
- `e77b3fb` [Docs] v0.1 UI + CI 플랜
- `4855cf7` [Docs] 하네스 엔지니어링 설계 문서

---
*Updated: 2026-04-15 17:05 (권한 실패 회고 + 다음 세션 진입 가이드)*
