# CI v0.1 Implementation Plan — GitHub Actions green + README badge

> **For Claude:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** `flutter analyze` + `flutter test` (coverage ≥ 80%) + spell-check가 `main` 브랜치 push/PR에서 자동 실행되고 **README CI 뱃지가 초록색으로 점등**되게 한다.

**Architecture:** VGV가 스캐폴드한 `main.yaml`을 ci.yml로 리네임 + 커버리지 임계값을 100% → 80%로 조정 + 한국어 마크다운 cspell 충돌 해결. GitHub reusable workflows(very_good_workflows)를 최대한 유지해 유지보수 부담 최소.

**Tech Stack:**
- GitHub Actions
- `VeryGoodOpenSource/very_good_workflows@v1` (재사용 workflow: `flutter_package.yml`, `semantic_pull_request.yml`, `spell_check.yml`)
- cspell (VGV 사전 상속)

---

## Context (서브에이전트 필독)

### 현재 상태
- `.github/workflows/main.yaml` — VGV 기본 워크플로우 (3 jobs: semantic-pull-request, build, spell-check)
- `.github/cspell.json` — VGV 스페인어 기본 사전 (한국어 없음)
- `README.md` 4줄에 CI 뱃지:
  ```
  [![CI](https://github.com/GthingkingG/will-i-make-it/actions/workflows/ci.yml/badge.svg)](https://github.com/GthingkingG/will-i-make-it/actions/workflows/ci.yml)
  ```
  현재 뱃지는 깨져 있음 (`ci.yml` 파일이 존재하지 않음, `main.yaml`임).

### 프로젝트 문서
- 전체 설계: `docs/DESIGN_v0.md`
- 하네스: `docs/plans/2026-04-15-harness-engineering-design.md`

### Freeze 스코프 (이 워크트리에서 허용)
- `.github/workflows/**`
- `.github/actions/**`
- `.github/cspell.json`
- `coverage_badge.svg` (필요 시 업데이트)
- `pubspec.yaml` **(dev_dependencies 한정)** — 커밋 메시지에 `[CI]` 태그 필수

### 절대 편집 금지
- `lib/**`, `test/**`, `ios/**`, `android/**` (UI 스트림 영역)
- `fastlane/**`, `supabase/**` (다른 Wave)
- `docs/plans/ci-v0.1-plan.md` 외 다른 플랜

### 코딩 규칙
- YAML 들여쓰기 2 spaces 일관
- Reusable workflow `uses:` 버전 핀 유지 (`@v1`)
- 커밋 메시지 태그: `[CI]` 또는 `[Chore]`

### Definition of Done
- [ ] `.github/workflows/ci.yml` 파일 존재, `.github/workflows/main.yaml` 제거
- [ ] PR push 시 GitHub Actions에서 모든 job green (Actions 탭 캡처)
- [ ] README 뱃지가 실제로 녹색으로 점등 (브라우저에서 확인)
- [ ] coverage threshold 80%로 설정됨 (원래 VGV 기본 100%)
- [ ] 한국어가 많이 포함된 마크다운(DESIGN_v0.md, SETUP.md, CLAUDE.md)에서 spell-check 통과 OR 해당 파일 명시적 제외
- [ ] PR description에 Actions 런 링크 + 뱃지 스크린샷 임베드

---

## Task 0: 워크트리 + 브랜치 확인

**Step 0.1: 현재 위치 확인**
```bash
git worktree list
git branch --show-current
```
Expected: 브랜치 `feat/ci-v0.1`, 경로 `.../will-i-make-it-worktrees/ci-v0.1/`.

메인 워크트리면 즉시 중단 + 보고.

**Step 0.2: main.yaml과 cspell.json 현재 상태 읽기**
```bash
cat .github/workflows/main.yaml
cat .github/cspell.json
head -5 README.md
```

---

## Task 1: main.yaml → ci.yml 리네임

**Files:**
- Rename: `.github/workflows/main.yaml` → `.github/workflows/ci.yml`

**Step 1.1: git mv**
```bash
git mv .github/workflows/main.yaml .github/workflows/ci.yml
```

**Step 1.2: workflow name 필드도 변경**

`.github/workflows/ci.yml` 파일 안 첫 줄:
```yaml
name: CI
```
(원래 `will_i_make_it`였음 → 단순화)

**Step 1.3: analyze (문법 확인)**

YAML 문법 오류 방지. 로컬에 `actionlint` 설치되어 있으면:
```bash
actionlint .github/workflows/ci.yml
```
없으면 스킵 — 첫 push 시 GH Actions가 검증.

**Step 1.4: 커밋**
```bash
git add .github/workflows/ci.yml
git commit -m "[CI] - main.yaml을 ci.yml로 리네임 (README 뱃지 URL 일치)"
```

---

## Task 2: coverage threshold 80%로 조정

VGV `flutter_package.yml`의 기본 coverage 임계값은 100%. v0.1 DoD는 80%.

**Files:**
- Modify: `.github/workflows/ci.yml`

**Step 2.1: build job에 min_coverage 파라미터 추가**

`.github/workflows/ci.yml` 내 `build` 섹션:
```yaml
  build:
    uses: VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v1
    with:
      flutter_version: "3.41.x"
      run_bloc_lint: true
      min_coverage: 80
```

**Note**: 파라미터명은 VGV workflow가 제공하는 것과 정확히 일치해야 함. 확인 URL: `https://github.com/VeryGoodOpenSource/very_good_workflows/blob/v1/.github/workflows/flutter_package.yml` 의 `inputs` 블록. 만약 이름이 다르면 (예: `coverage_threshold`) 그에 맞춰 수정.

**Step 2.2: 커밋**
```bash
git add .github/workflows/ci.yml
git commit -m "[CI] - coverage threshold 100% → 80% (v0.1 DoD)"
```

---

## Task 3: cspell 한국어 마크다운 대응

v0.1은 한국어 primary 프로젝트. DESIGN_v0.md/SETUP.md/CLAUDE.md/CHANGELOG.md/docs/plans/*.md는 한국어 위주 — VGV 스페인어 사전으로는 전부 spell error.

**대응 전략**: spell-check job 대상을 **한국어 비중 낮은** 마크다운만으로 좁힌다 (README.md만).

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/cspell.json`

**Step 3.1: workflow includes 수정**

`.github/workflows/ci.yml`의 spell-check 섹션:
```yaml
  spell-check:
    uses: VeryGoodOpenSource/very_good_workflows/.github/workflows/spell_check.yml@v1
    with:
      includes: |
        README.md
      modified_files_only: false
```

(원래 `**/*.md`였음)

**Step 3.2: cspell.json 정리**

VGV 기본 스페인어 단어 제거 + 프로젝트 고유어 추가:

```json
{
  "version": "0.2",
  "$schema": "https://raw.githubusercontent.com/streetsidesoftware/cspell/main/cspell.schema.json",
  "dictionaries": ["vgv_allowed", "vgv_forbidden"],
  "dictionaryDefinitions": [
    {
      "name": "vgv_allowed",
      "path": "https://raw.githubusercontent.com/verygoodopensource/very_good_dictionaries/main/allowed.txt",
      "description": "Allowed VGV Spellings"
    },
    {
      "name": "vgv_forbidden",
      "path": "https://raw.githubusercontent.com/verygoodopensource/very_good_dictionaries/main/forbidden.txt",
      "description": "Forbidden VGV Spellings"
    }
  ],
  "useGitignore": true,
  "ignoreRegExpList": [
    "/[\\p{Script=Hangul}]+/gu"
  ],
  "words": [
    "HUFS",
    "gstack",
    "superpowers",
    "verygood",
    "verygoodventures",
    "Supabase",
    "Fastlane",
    "TestFlight",
    "bloc",
    "cubit",
    "geolocator",
    "permission handler",
    "pubspec",
    "lcov"
  ]
}
```

주요 변경:
- `ignoreRegExpList`에 한글 유니코드 블록(`\p{Script=Hangul}`) 추가 — README에 한글이 있어도 무시
- 스페인어 단어(Contador, Hola 등) 제거
- 프로젝트 고유어 추가

**Step 3.3: 커밋**
```bash
git add .github/workflows/ci.yml .github/cspell.json
git commit -m "[CI] - 한국어 마크다운 cspell 대응 (Hangul regex ignore + include scope 축소)"
```

---

## Task 4: 첫 push + CI green 확인

**Step 4.1: 브랜치 push**
```bash
git push -u origin feat/ci-v0.1
```

**Step 4.2: PR 생성 (draft로 먼저)**
```bash
gh pr create --draft --title "feat: v0.1 CI — GitHub Actions green + README 뱃지" --body "WIP — 첫 CI 런 확인 중"
```

**Step 4.3: Actions 런 모니터**
```bash
gh pr checks  # 또는 gh run list --branch feat/ci-v0.1 --limit 5
gh run watch <run-id>
```

**Step 4.4: 실패 시 원인 분석**

실패 jobs별 대응:
- **semantic-pull-request**: PR 제목이 conventional commit 형식이어야 함. `feat:`, `fix:`, `chore:`로 시작. 이미 위 title에 `feat:` 포함.
- **build**: 
  - analyze 에러: UI 워크트리와 동기화 필요 (main branch rebase)
  - coverage 부족: UI agent 아직 테스트 안 썼을 수도. 이 경우 **임시로 min_coverage: 0** 설정 + 주석에 "UI v0.1 머지 전까지 완화" 남기고 나중에 80% 복구
- **spell-check**: 
  - 한글 regex 미작동 → `\p{Script=Hangul}` 대신 `[가-힣]+` 시도
  - 다른 언어(영어) 단어 실패 → cspell.json `words` 배열 보강

**Step 4.5: 반복 — green까지**

런이 green 될 때까지 수정-커밋-push 반복. 각 수정은 독립 커밋.

**Step 4.6: README 뱃지 렌더링 육안 확인**

GitHub에서 `README.md` 미리보기 열기:
```bash
gh repo view --web
```
뱃지가 "CI | passing" 초록색으로 보이면 성공. 빨간색이면 캐시 문제일 수 있으니 shift+reload.

---

## Task 5: PR green 상태로 전환 + Evidence

**Files:**
- Create: `docs/evidence/ci-v0.1-actions-green.png`
- Create: `docs/evidence/ci-v0.1-readme-badge.png`

**Step 5.1: 스크린샷 캡처**

macOS 기준:
- `Cmd+Shift+4` + Space → Actions 페이지 브라우저 창 캡처 → `~/Desktop` 저장 후 이동
- README 뱃지 부분 캡처 (확대해서 선명하게)

```bash
mv ~/Desktop/Screen\ Shot*.png docs/evidence/ci-v0.1-actions-green.png
# 두 번째도 동일
```

**Step 5.2: 증거 커밋**
```bash
git add docs/evidence/
git commit -m "[Docs] - v0.1 CI green 증거 스크린샷"
git push
```

**Step 5.3: PR ready for review 전환**
```bash
gh pr ready
gh pr edit --title "feat: v0.1 CI — GitHub Actions green + README 뱃지" --body "$(cat <<'EOF'
## Summary

VGV 기본 workflow를 프로젝트 규약에 맞게 조정한다.

### 변경 사항
- `main.yaml` → `ci.yml` 리네임 (README 뱃지 URL 일치)
- Coverage threshold 100% → 80% (v0.1 DoD)
- 한국어 마크다운 cspell 대응 (Hangul regex ignore + include scope)

### Jobs (3개 모두 green)
- `semantic-pull-request` — PR 제목 컨벤션
- `build` — analyze + test + coverage ≥ 80%
- `spell-check` — README.md 한정

### Evidence
- `docs/evidence/ci-v0.1-actions-green.png`
- `docs/evidence/ci-v0.1-readme-badge.png`

### Quality gates
- [x] 모든 Actions job green
- [x] README 뱃지 초록 점등
- [x] coverage_threshold=80 명시

## Test plan
- [ ] 이 PR 머지 후 main 브랜치에서도 재실행되어 green 확인
- [ ] UI v0.1 PR 머지 후 cspell에 새 한국어 문서가 들어와도 무관함 확인

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Task 6: 메인 세션 반환 리포트

실행 끝나면 주제 줄 한 개에 결과 요약:

```
## CI v0.1 Plan — 완료 상태
- PR URL: <출력된 URL>
- 모든 3 jobs green (semantic / build / spell)
- coverage 실측: X% (≥ 80%)
- 뱃지: 초록 점등 (evidence 첨부)
- 블로커: 없음 / 있음 (상세)
- 다음 단계: codex review + merge
```

---

## Troubleshooting

### 1. `min_coverage` 파라미터 이름이 다르면
실제 VGV workflow input 이름 확인:
```bash
curl -s https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_workflows/v1/.github/workflows/flutter_package.yml | grep -A 2 "inputs:"
```

### 2. UI agent가 아직 `test/` 디렉토리를 만들지 않았을 때 coverage fail
일시적으로 `min_coverage: 0`으로 PR 머지 → UI PR 머지 후 main에서 80%로 복구. 이 경우 PR description에 "임시 완화 — UI PR 머지 후 복구" 명시 + 후속 이슈 생성.

### 3. cspell이 한글 regex를 인식 못 함
cspell 버전에 따라 유니코드 regex 지원 상이. 대안:
```json
"ignoreRegExpList": ["[\u3131-\uD79D]+"]
```

### 4. semantic-pull-request 실패 (PR 제목)
제목이 `feat:`, `fix:`, `chore:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:` 중 하나로 시작해야 함.

### 5. very_good_workflows v1이 deprecated된 경우
최신 태그 확인:
```bash
gh api repos/VeryGoodOpenSource/very_good_workflows/tags --jq '.[0].name'
```

---

## Scope guard

- ❌ `deploy.yml` (TestFlight/Play Internal 자동 배포) — Wave 3 (Fastlane 완료 후)
- ❌ `lib/**` 또는 `test/**` 편집 — UI 스트림 영역
- ❌ 새 dependency 추가 (runtime) — UI 스트림이 우선권
- ❌ iOS/Android 설정 파일 편집

---

## Execution

**Plan complete and saved to `docs/plans/ci-v0.1-plan.md`. Two execution options:**

**1. Subagent-Driven (this session)** — 메인 세션이 task마다 fresh subagent dispatch.

**2. Parallel Session (separate)** — worktree에서 `superpowers:executing-plans` batch 실행.

Wave 1 의도라면 UI 플랜과 함께 **2번 병렬 dispatch**가 원래 계획.

**Which approach?**
