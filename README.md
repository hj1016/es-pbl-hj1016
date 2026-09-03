# DevFix — 개발 오류 해결 사례 검색

## 1. 프로젝트 소개

- 문제와 사용자: 개발자는 오류가 발생했을 때 검색 결과에 서로 다른 기술 버전이나 실행 환경의 해결 방법이 섞여 있어, 현재 환경에 맞는 해결 사례를 찾는 데 많은 시간을 사용한다. 이 프로젝트의 사용자는 오류의 원인과 검증된 해결 방법을 빠르게 찾고 싶은 개발자이다.
- ES로 검색할 문서 1건: 오류 제목, 증상, 오류 메시지, 사용 기술과 버전, 운영체제, 발생 원인, 해결 방법, 검증 여부를 담은 개발 오류 해결 사례 1건이다.
- ES의 역할: 오류 메시지와 증상을 전문 검색하고 기술·버전·운영체제·오류 유형·검증 여부로 결과를 필터링하여, 현재 환경과 관련성이 높은 해결 사례를 제공한다.
- 이 주제를 선택한 이유: 오류 메시지와 증상은 전문 검색이 필요하고, 기술·버전·운영체제·오류 유형·검증 여부에 따른 필터도 필요하다. Elasticsearch의 검색, 필터, 정렬, 집계 기능을 함께 적용하기 적합하며 실제 개발 과정에서도 활용할 수 있기 때문에 선택했다.

## 2. 실행 순서

1. Docker 환경 시작: 강의 저장소의 `day-01/docker`에서 `.env.example`을 `.env`로 복사하고 교육용 비밀번호를 입력한 뒤, `docker compose pull` → `docker compose up --detach` → `docker compose ps --all` 순서로 실행한다. ES 9.5.0의 `es01`, `es02`, `es03`과 Kibana가 모두 `healthy`이고, cluster 상태가 `green`이며 `number_of_nodes`가 `3`인 것을 확인했다.
2. index와 mapping 생성: `devfix-cases`가 없는 것을 확인한 뒤 primary shard 1개, replica 1개, `dynamic: strict`와 14개 field mapping으로 생성했다. 생성 후 primary와 replica가 모두 `STARTED`이고 cluster가 `green`인 것을 확인했다.
3. 데이터 생성·Bulk 적재: seed `20260901`로 합성 오류 사례 50,000건과 표본 30건을 생성했다. 로컬 schema·ID·NDJSON 검사를 통과한 뒤 Bulk API로 적재했으며 `errors=false`와 실제 `_count` 50,000건을 확인했다.
4. 검색 요청 실행: `term`, `match`, `multi_match`, `bool`, `range`, `sort`를 단계별로 검증했다. 최종 검색 앱은 제목·오류 메시지·증상·원인·해결 방법을 함께 검색하고, `verified=true`를 적용한 뒤 관련도 → 해결 시간 → 도움됨 횟수 순으로 정렬한다. `Docker unhealthy` 조건을 더 엄격하게 적용한 개인 bool 검색에서는 744건이 조회됐다.
5. Kibana Dashboard 확인: `DevFix Dashboard` Data View로 전체 50,000건을 확인하고 Metric, Table, Donut, Bar 2개, Line, Heat map의 총 7개 패널을 구성했다. `error_category=configuration` Control 적용 시 전체 건수가 50,000건에서 8,387건으로 바뀌고 관련 패널이 함께 갱신되는 것을 확인했다.

## 3. 데이터와 mapping

- 문서 수: 합성 오류 해결 사례 50,000건, 제출용 표본 30건
- 데이터 생성 규칙과 seed: seed `20260901`을 사용해 기술·버전·운영체제·오류 유형·검증 여부·해결 시간 등의 후보와 범위에서 재현 가능한 데이터를 생성했다.
- 개인정보 미사용 확인: 개발자 실명·이메일·사번, 고객정보, 실제 내부 IP·호스트명, 계정·비밀번호·token과 실제 운영 로그를 사용하지 않았다.
- 핵심 필드와 타입 선택 이유: 제목·증상·원인·해결 방법은 전문 검색을 위해 `text`, 기술·버전·운영체제·오류 유형은 정확한 filter와 집계를 위해 `keyword`로 정의했다. `error_message`는 전문 검색과 정확 비교를 모두 지원하도록 `text`와 `keyword` multi-field를 사용했다. 검증 여부는 `boolean`, 해결 시간과 도움됨 횟수는 `integer`, 등록일은 `date`로 정의했다.

## 4. 검색·품질 테스트

| 검색 질문 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|
| Docker에서 발생한 `unhealthy` 오류 사례를 찾아줘. | `title`, `error_message`, `symptoms` 중 검색 의도와 관련된 사례가 상위에 표시된다. | 상위 3건 `DEVFIX-0002`, `DEVFIX-0039`, `DEVFIX-0069`가 모두 Docker 환경의 unhealthy 오류 사례였다. | 통과 |
| Docker의 `unhealthy` 오류 중 검증 완료되고 120분 이내에 해결된 사례를 찾아줘. | `technology=Docker`, `verified=true`, `resolution_minutes<=120`을 모두 만족한다. | 총 744건이 조회됐고 확인한 상위 문서가 모든 조건을 만족했다. | 통과 |
| `unhealthy` 사례를 빠르게 해결할 수 있고 도움됨 횟수가 높은 순으로 보여줘. | 해결 시간 오름차순, 동률이면 도움됨 횟수 내림차순으로 정렬된다. | 상위 5건이 모두 최소 5분이었고 도움됨 횟수가 `200 → 198 → 191 → 176 → 176` 순이었다. | 통과 |

상세 실행 요청과 결과는 [`evidence/day-03-practice`](evidence/day-03-practice)에서 확인할 수 있다.

## 5. Dashboard

- Dashboard 사용자: 개발 오류 해결 사례의 규모와 분포를 파악하고 우선 검토할 사례를 정하려는 개발자
- 차트 1이 답하는 질문: 오류 유형별 사례 수는 어떻게 분포하는가?
- 차트 2가 답하는 질문: 해결 시간 구간별 사례 수와 오류 유형별 해결 시간 분포는 어떠한가?
- control/filter 목적: `error_category`와 `technology`를 선택해 전체 패널을 같은 조건으로 좁히고 유형·기술별 결과를 비교한다.

![Day 4 DevFix Dashboard](evidence/day-04/assets/devfix-dashboard-overview.png)

Dashboard 설계와 검증 결과는 [`dashboard-plan.md`](evidence/day-04/dashboard-plan.md)와 [`dashboard-review.md`](evidence/day-04/dashboard-review.md)에서 확인할 수 있다.

## 6. AI Search 확장 판단

- 적용 여부와 근거: 현재 단계에서는 적용하지 않았다. 오류 코드·제품명·기술명처럼 정확한 문자열과 구조화된 filter가 중요한 데이터이므로 `multi_match`와 bool filter만으로 기본 검색 요구를 충족했다. 이후 사용자가 오류 메시지를 그대로 입력하지 않고 자연어로 증상을 설명하는 사례가 늘어나면, 기존 키워드 검색을 유지하면서 의미 기반 검색을 결합한 hybrid search를 비교 실험한다.
