# 8교시 연습 — 사용 시나리오·교차 검증·개선·제출

- 필수 권장 시간: 45분
- 선택 도전: 필수 제출 완료 후
- 함께 작성: `../day-04/dashboard-review.md`
- 시작 기준: 개인 Dashboard 4패널 이상과 상호작용 1개 저장 완료
- 화면 순서: [Inspect·결과 저장·백업](https://github.com/djkorea/es-5days-pbl-course/blob/main/day-04/KIBANA_9_5_STEP_BY_STEP.md#15-결과-저장공유백업)

## (개인·필수) 문제 1 — 사용자 행동 두 가지 테스트

Dashboard 사용자가 실제로 할 행동 두 가지를 실행하세요. 각 행동은 조건 적용과 결과 확인, 원상 복구를 포함합니다.

| 행동 | 시작 상태 | 적용 조건 | 변한 패널·값 | 사용자의 판단 | 복구 방법 | 복구 성공 |
|---|---|---|---|---|---|---|
| 1 | 전체 50,000건, Control `Any`, KQL·filter 없음 | `error_category=configuration` | Metric 50,000→8,387, Docker 사례 수 12,535→2,187, 평균 해결 시간 122.369→123.627분 | configuration 사례만 좁혀 규모와 기술별 해결 시간을 확인한다. | Control을 `Any`로 변경 | 50,000건 복구 |
| 2 |  |  |  |  |  |  |

- 두 행동이 서로 다른 이유:
- 사용자가 멈추거나 헷갈린 지점:
- 캡처 파일: `../day-04/assets/devfix-configuration-filter.png`

## (개인·필수) 문제 2 — 핵심값 3개 교차 검증

Dashboard의 핵심값 3개를 Discover, `_count`, 또는 aggregation 요청과 비교하세요. `Inspect`는 Dashboard 편집 모드에서 해당 패널의 `Panel menu`에 있습니다. 권한이나 화면 상태로 보이지 않으면 Discover 또는 제공 요청 파일로 검증합니다.

| Dashboard 패널·값 | 동일하게 맞춘 시간·조건 | 비교 방법 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---|---:|---|---|
| 전체 오류 사례 수 50,000 | 2024-12-31 00:00~2026-08-31 00:00, KQL·filter 없음, Control `Any` | `GET /devfix-cases/_count` | 50,000 | 일치 | - |
| configuration 사례 수 8,387 | 같은 시간 범위, `error_category=configuration` | `error_category` terms aggregation | 8,387 | 일치 | - |
| verified true 37,596 / false 12,404 | 같은 시간 범위, KQL·filter 없음, Control `Any` | `verified` terms aggregation | 37,596 / 12,404 | 일치 | - |

- 비교에 사용한 요청 파일 또는 Discover 캡처: `assets/devfix-discover-50000.png`, `../day-04/dashboard-review.md`
- 세 값을 신뢰할 수 있는 이유: Dashboard와 Elasticsearch `_count`·terms aggregation에 같은 index와 조건을 적용했을 때 값이 일치했다.

## (개인·필수) 문제 3 — 문제 하나를 실제로 수정하고 재검증

제목, field, 집계, 정렬, 구간, 시간, filter, layout 중 한 문제를 골라 수정하세요. 문제가 없다고 생각되면 사용성 문제 하나를 개선합니다.

- 발견한 문제: Heat map의 긴 `error_category` 라벨이 좁은 패널에서 겹쳤다.
- 문제 유형: layout
- 수정 전 설정 또는 결과: 패널 폭이 좁아 x축 오류 유형 이름을 읽기 어려웠다.
- 추정 원인: 긴 영문 범주 6개를 좁은 x축에 표시했다.
- 수정한 한 가지: Heat map 패널의 폭을 늘렸다.
- 수정 후 결과: 셀 색상과 y축 해결 시간 구간을 더 쉽게 확인할 수 있었다.
- 같은 조건 재검증 결과: 오류 유형 6개와 해결 시간 5개 구간이 유지됐다.
- 개선/보류/악화 판정과 근거: 보류. 패널 가독성은 좋아졌지만 긴 영문 x축 라벨의 일부 겹침이 남았다.
- 수정 전·후 캡처: `../day-04/assets/devfix-dashboard-overview.png`

## (개인·필수) 문제 4 — 결과 3·한계 2·필요 데이터 1과 제출

### 결과 3개

1. 조건·핵심값·비교·판단: 전체 조건에서 오류 유형 6개가 각각 약 8,300건으로 비슷하게 분포하므로 사례 수만으로 특정 오류 유형의 중요도를 단정하지 않는다.
2. 조건·핵심값·비교·판단: 전체 조건에서 검증 완료 37,596건과 미검증 12,404건이 확인됐으므로 미검증 사례를 별도 filter로 점검할 수 있다.
3. 조건·핵심값·비교·판단: `configuration` 적용 시 전체 50,000건이 8,387건으로 줄고 Docker 사례 수도 12,535건에서 2,187건으로 바뀌므로 Control이 관련 패널에 함께 적용된다고 판단했다.

### 현재 데이터의 한계 2개

1. `technology`, `error_category`, `resolution_minutes`가 독립적으로 생성된 합성 데이터이므로 기술별 실제 오류 빈도나 난이도를 단정할 수 없다.
2. `created_at`은 사례 등록 시점이며 실제 오류 발생 시점이 아니므로 Line 차트를 장애 발생 추세로 해석할 수 없다.

### 추가로 필요한 데이터 1개

- field: `severity`
- mapping type: `keyword`
- 예시값: `P1`, `P2`, `P3`, `P4`
- 값 분포·생성 규칙: 기존 50,000건에 P1~P4를 배정하되 P1은 적고 P3·P4는 많게 분포시키며 seed `20260901`을 고정한다.
- 추가되면 답할 수 있는 질문: 심각도별 오류 사례 수와 평균 해결 시간은 어떻게 다른가?

### 제출 기록

- Dashboard 제목: `Day 4 - DevFix`
- 전체 화면 캡처 경로: `../day-04/assets/devfix-dashboard-overview.png`
- JSON export 경로(선택):
- `dashboard-plan.md` 경로: `../day-04/dashboard-plan.md`
- `dashboard-review.md` 경로: `../day-04/dashboard-review.md`
- 개인 저장소 commit SHA: `20b1de2`
- 알려진 제한 사항: Heat map의 긴 영문 x축 라벨 일부가 겹쳐 보인다.

PDF 메뉴가 없으면 정상입니다. 현재 수업 환경의 `More → Export`는 Dashboard JSON을 제공하며, 관련 객체까지 옮길 때는 `Stack Management → Kibana → Saved Objects → Export`를 사용합니다. 화면 캡처를 기본 근거로 제출합니다.

## (선택 도전) 문제 5 — 다른 사람이 재현할 수 있는지 점검

자신의 기록만 보고 다음 항목을 다시 수행해 보거나 옆 학생에게 문서만 보여 줍니다.

- [ ] 올바른 Data View를 선택할 수 있다.
- [ ] 시간 범위를 동일하게 맞출 수 있다.
- [ ] Control/Filter 조건을 재현할 수 있다.
- [ ] 핵심값 3개의 비교 근거를 찾을 수 있다.
- [ ] Dashboard를 초기 상태로 복구할 수 있다.

- 재현에 부족했던 설명:
- 추가한 설명:
- 최종 재현 판정:

## Day 4 최종 완료 신호

- GREEN: 필수 32문제의 요구 산출물, 개인 Dashboard, plan/review, 캡처, commit 완료
- YELLOW: Dashboard는 있으나 검증·개선·commit 중 하나가 미완료
- RED: 저장된 Dashboard 또는 제출 근거가 없음
