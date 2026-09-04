# 7교시 연습 — 개인 목적형 Dashboard 제작

- 필수 권장 시간: 43분
- 선택 도전: 2분
- 제출 상태 확인: 5분
- 시작 기준: `dashboard-plan.md`의 질문 4개와 A/B/C 경로 확정
- 화면 순서: [Save as](https://github.com/djkorea/es-5days-pbl-course/blob/main/day-04/KIBANA_9_5_STEP_BY_STEP.md#142-개인본-만들기), [선택 확장 패널](https://github.com/djkorea/es-5days-pbl-course/blob/main/day-04/KIBANA_9_5_STEP_BY_STEP.md#16-선택-확장-패널)

## (개인·필수) 문제 1 — 공통 원본을 보존하고 개인본 만들기

공통 Dashboard를 `Save as` 또는 `Duplicate`하여 개인본을 만드세요. 공통 원본에 덮어쓰지 않습니다.

- 공통 원본 이름:
- 개인본 이름 `D4 개인 미션 - 주제 - 이름`:
- 사용한 복제 방법:
- 상단 제목이 개인본으로 바뀌었는가:
- Dashboard 목록에 원본과 개인본이 모두 있는가:
- 캡처 파일:

## (개인·필수) 문제 2 — 청사진대로 서로 다른 패널 4개 제작

질문 Q1~Q4를 답하는 패널을 최소 4개 만드세요. 공통 Dashboard와 비교해 field·집계·정렬·구간·제목 중 두 가지 이상을 개인 질문에 맞게 바꿉니다.

| 질문 | 패널 제목 | field | 계산·그룹 | 차트 | 실제 결과 | 완료 기준 통과 |
|---|---|---|---|---|---|---|
| Q1 | 전체 오류 사례 수 | Records | Count | Metric | 50,000건 | 통과 |
| Q2 | 오류 유형별 사례 수 | `error_category` | Top values 6 + Count | Bar | cluster_discovery 8,419건, configuration 8,387건, dependency 8,331건, container_health 8,313건, network_connection 8,280건, authentication 8,270건 | 통과 |
| Q3 | 기술별 사례 수와 평균 해결 시간 | `technology`, `resolution_minutes` | Top values 6 + Count + Average | Table | 기술 6개의 사례 수와 평균 해결 시간이 표시됐다. | 통과 |
| Q4 | 검증 여부 비율 | `verified` | Top values + Count | Donut | true 37,596건(75.19%), false 12,404건(24.81%) | 통과 |

- 공통본에서 변경한 요소 2개 이상: `products`의 상품 field를 DevFix의 `error_category`, `technology`, `verified`, `resolution_minutes`, `created_at`으로 변경했고, 해결 시간 사용자 구간과 개인 질문형 패널 제목을 적용했다.
- 만들지 못한 패널과 이유:
- 사용한 대체 질문 또는 데이터 보강 계획:

## (개인·필수) 문제 3 — 제목과 배치만 보고 질문을 이해하게 만들기

각 제목을 `Bar`, `그래프`, `현황` 같은 차트 이름이 아니라 사용자가 알게 되는 내용으로 바꾸세요.

| 수정 전 제목 | 수정 후 제목 | 사용자가 알게 되는 것 |
|---|---|---|
| Count of records | 전체 오류 사례 수 | 저장된 오류 해결 사례의 전체 규모 |
| Top values of error_category | 오류 유형별 사례 수 | 오류 유형별 사례 규모 |
| Intervals of resolution_minutes | 해결 시간 구간별 사례 수 | 해결 시간 구간마다 포함된 사례 규모 |
| Date histogram of created_at | 월별 오류 사례 등록 분포 | 월별로 등록된 사례 수의 변화 |

- 가장 중요한 패널: 전체 오류 사례 수 Metric
- 가장 크게 배치한 이유: Heat map은 오류 유형과 해결 시간 구간을 동시에 읽어야 하므로 넓게 배치했다.
- 잘림·겹침을 수정한 패널: 오류 유형별 해결 시간 분포 Heat map
- 수정 후 전체 화면 캡처: `../day-04/assets/devfix-dashboard-overview.png`

## (개인·필수) 문제 4 — 개인 질문용 Control 또는 Filter

사용자가 반복해서 바꿀 조건 하나를 Control로 만들거나, 항상 유지할 조건 하나를 Filter로 추가하세요.

- 선택한 방식: Control
- field: `error_category`
- label 또는 조건: `오류 유형 선택`
- 이 조건이 필요한 사용자 행동: 특정 오류 유형만 선택해 규모·기술·해결 시간·검증 상태를 함께 비교한다.
- 적용 전 핵심값: 전체 50,000건
- 적용 후 핵심값: `configuration` 선택 시 8,387건
- 함께 변한 다른 패널: 기술별 Table의 Docker 사례 수가 12,535건에서 2,187건으로 바뀌고 평균 해결 시간이 122.369분에서 123.627분으로 바뀌었다.
- 해제 방법: Control 값을 `Any`로 복구
- 해제 후 복구값: 전체 50,000건
- 캡처 파일: `../day-04/assets/devfix-configuration-filter.png`

## (선택 도전) 문제 5 — 확장 차트 하나의 필요성 심사

Gauge, Heatmap, Treemap, Tag cloud 중 하나가 자신의 질문에 정말 필요한지 먼저 판단하세요.

- 후보 차트: Heat map
- 답하려는 질문: 오류 유형별 해결 시간 구간의 사례 수는 어떻게 분포하는가?
- 필요한 field: `error_category`, `resolution_minutes`
- 기본 Bar/Table보다 나은 점: 두 범주 축의 조합별 규모를 셀 색상으로 한 번에 비교할 수 있다.
- 오해할 위험: 색상 차이만 보고 작은 수치 차이를 과장하거나 합성 데이터의 분포를 실제 난이도로 해석할 수 있다.
- 추가/보류 결정: 추가
- 추가했다면 검증 결과: 오류 유형 6개와 해결 시간 5개 구간이 표시됐으며, 긴 영문 x축 라벨은 일부 겹침이 남았다.

질문에 필요하지 않으면 만들지 않는 것도 정상 답입니다.

## 교시 완료 신호

- GREEN: 개인본, 4패널, 의미 있는 제목·배치, 상호작용 1개 완료
- YELLOW: 3패널 또는 상호작용 검증 미완료
- RED: 개인 Dashboard 복제나 저장 불가
