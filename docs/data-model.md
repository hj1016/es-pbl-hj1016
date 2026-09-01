## Day 1 데이터 모델 초안

### 1. 문서 단위

- 검색 결과 한 건은 무엇인가: 개발 오류 해결 사례 1건
- 이 문서 한 건이 사용자에게 보여 주는 정보는 무엇인가: 오류 제목, 증상, 오류 메시지, 사용 기술과 버전, 운영체제, 발생 원인, 해결 방법, 검증 여부, 해결 소요 시간

### 2. 대표 문서 예시

실제 개인정보나 실제 시스템의 비밀정보를 사용하지 않은 합성 예시다.

```json
{
  "case_id": "DEVFIX-0001",
  "title": "Docker 환경에서 Elasticsearch master 노드를 찾지 못하는 오류",
  "symptoms": "Elasticsearch 노드가 클러스터를 구성하지 못하고 시작을 반복한다.",
  "error_message": "master_not_discovered_exception",
  "technology": ["Elasticsearch", "Docker"],
  "version": "9.5.0",
  "os": "macOS",
  "error_category": "cluster_discovery",
  "cause": "노드 탐색 설정과 Docker 네트워크의 노드 이름이 일치하지 않았다.",
  "solution": "discovery.seed_hosts와 컨테이너 이름을 일치시킨 뒤 클러스터를 다시 시작했다.",
  "verified": true,
  "resolution_minutes": 30,
  "helpful_count": 12,
  "created_at": "2026-08-31T15:00:00+09:00"
}
```

### 3. 핵심 field와 역할

| field | 예시 값 | 검색에서 맡는 역할 | ES type 후보 | 선택 이유 |
|---|---|---|---|---|
| `case_id` | `DEVFIX-0001` | 정확 조건, 표시 | `keyword` | 사례를 정확한 값으로 식별한다. |
| `title` | Docker 환경에서 Elasticsearch master 노드를 찾지 못하는 오류 | 전문 검색, 표시 | `text` | 제목의 여러 단어를 분석해 검색한다. |
| `symptoms` | Elasticsearch 노드가 클러스터를 구성하지 못한다 | 전문 검색, 표시 | `text` | 사용자가 자연어로 설명한 증상과 연결한다. |
| `error_message` | `master_not_discovered_exception` | 전문 검색, 정확 조건, 표시 | `text` + `keyword` multi-field | 일부 문자열 검색과 오류 원문 전체 비교가 모두 필요하다. |
| `technology` | Elasticsearch, Docker | 정확 조건, 집계, 표시 | `keyword` 배열 | 기술별 filter와 Dashboard 집계에 사용한다. |
| `version` | `9.5.0` | 정확 조건, 표시 | `keyword` | 버전은 분석하지 않고 정확히 비교한다. |
| `os` | `macOS` | 정확 조건, 집계, 표시 | `keyword` | 운영체제별 filter와 집계에 사용한다. |
| `error_category` | `cluster_discovery` | 정확 조건, 집계 | `keyword` | 오류 유형별 filter와 Dashboard 집계에 사용한다. |
| `cause` | 노드 탐색 설정 불일치 | 전문 검색, 표시 | `text` | 원인 설명의 여러 단어를 검색한다. |
| `solution` | 탐색 설정과 컨테이너 이름을 일치시킨다 | 전문 검색, 표시 | `text` | 해결 절차를 자연어로 검색하고 보여 준다. |
| `verified` | `true` | 정확 조건, 집계 | `boolean` | 검증 완료 여부를 참·거짓 조건으로 구분한다. |
| `resolution_minutes` | `30` | 범위, 정렬, 집계 | `integer` | 해결 시간 비교와 평균 집계에 사용한다. |
| `helpful_count` | `12` | 범위, 정렬, 집계 | `integer` | 도움됨 횟수순 정렬과 통계에 사용한다. |
| `created_at` | `2026-08-31T15:00:00+09:00` | 범위, 정렬 | `date` | 기간 filter와 최신 등록순 정렬에 사용한다. |

### 4. 검색 질문과 field 연결

| 검색 질문 | 사용할 field | 확인할 역할 |
|---|---|---|
| Elasticsearch 9.x Docker 환경에서 `master_not_discovered_exception`이 발생한 원인과 해결 방법은 무엇인가? | `error_message`, `technology`, `version`, `cause`, `solution` | 오류 전문 검색, 기술·버전 filter, 원인·해결 방법 표시 |
| macOS에서 Docker 컨테이너가 `unhealthy` 상태가 된 사례 중 검증된 해결 방법은 무엇인가? | `symptoms`, `technology`, `os`, `verified`, `solution` | 증상 전문 검색, 기술·OS·검증 여부 filter, 해결 방법 표시 |
| Spring Boot에서 `Connection refused`가 발생한 사례 중 현재 기술 버전과 일치하는 해결 방법은 무엇인가? | `error_message`, `technology`, `version`, `cause`, `solution` | 오류 전문 검색, 기술·버전 filter, 원인·해결 방법 표시 |

### 5. 제외할 데이터

- 수집하거나 저장하지 않을 개인정보: 개발자 실명·이메일·사번, 고객정보, 실제 내부 IP·호스트명, 계정·비밀번호·token, 공개할 수 없는 실제 운영 로그
- 제외 이유: 검색 기능 구현에 필요하지 않으며 개인정보와 시스템 비밀정보의 유출 위험을 방지하기 위해 합성 데이터만 사용한다.

## V1-T09-P · 문서 단위

- 개인 index 이름: `devfix-cases`
- 검색 결과 한 줄 / 문서 한 건의 의미: 오류 메시지, 실행 환경, 발생 원인, 해결 방법과 검증 결과를 담은 개발 오류 해결 사례 1건
- 업무 ID field / 예시 값: `case_id` / `DEVFIX-0001`
- ES `_id`와 업무 ID 관계: Bulk 적재 시 ES `_id`에 `case_id`와 같은 값을 명시적으로 사용한다. 두 값은 자동으로 동기화되지 않는다.

## V1-T10-P · 질문3개

| 번호 | 사용자 질문 | 검색어 | 조건 | 정렬 | 표시 field |
|---|---|---|---|---|---|
| Q1 | | | | | |
| Q2 | | | | | |
| Q3 | | | | | |

대표3건은 ../data/sample-documents.json에 저장한다.

| 문서 | 포함/제외/경계 역할 | 연결 질문 | 예상과 field 근거 |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

## V1-T11-P · field 계약

| field | 예시 값 | 검색/필터/정렬/표시/집계 | type | 질문 번호 | 선택 이유 |
|---|---|---|---|---|---|
| | | | | | |

- 배열/객체 여부와 제공 생성기 지원 범위:
- 제외한 개인정보/불필요한 field와 이유:
- 자가 점검으로 수정한 내용:
- 완전한 mapping: ../elasticsearch/index-create.json
