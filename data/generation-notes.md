# DevFix 데이터 생성·적재 기록

## 생성 설정

- 실행일: 2026-09-01
- 대상 index: `devfix-cases`
- 문서 수: 50,000건
- seed: `20260901`
- 업무 ID field: `case_id`
- ID 형식: `DEVFIX-0001`부터 순차 생성
- 표본 수: 30건
- mapping 정본: `elasticsearch/index-create.json`

## 생성 파일

- 전체 Bulk 파일: `data/pbl-data-template/generated/devfix-cases-50000.ndjson` (약 33MB, Git 제외)
- 제출용 표본: `data/pbl-data-template/generated/devfix-cases-sample-30.ndjson`
- 생성 요약과 해시: `data/pbl-data-template/generated/generation-summary.json`

## 실제 검증 결과

- 로컬 검사: `LOCAL CHECK PASS: 50000 documents, unique IDs, target index and NDJSON verified.`
- Bulk 응답: `errors=false`
- 생성 건수와 실제 ES count: 50,000건 / 50,000건
- cluster health: `green`
- shard: primary 1개와 replica 1개 모두 `STARTED`
- 저장 크기: primary와 replica 각각 약 9.3MB
- 검증 완료: 데이터 타입, 고유 ID, `_id`와 `case_id`, 대상 index, NDJSON 형식, mapping 일치

## 주요 분포

- 기술별 문서 수: Spring Boot 12,672, MySQL 12,588, Redis 12,566, Docker 12,535, Elasticsearch 12,448, Kibana 12,230
- 오류 유형별 문서 수: cluster_discovery 8,419, configuration 8,387, dependency 8,331, container_health 8,313, network_connection 8,280, authentication 8,270
- 검증 여부: `true` 37,596건, `false` 12,404건
- 해결 시간: 최소 5분, 최대 240분, 평균 122.2184분

`technology`는 문서마다 1~2개가 들어갈 수 있어 기술별 문서 수의 합은 전체 문서 수보다 클 수 있다.

## 실행 중 확인한 호환성

- PowerShell 7.5 이상에서는 ISO JSON 날짜 문자열이 `DateTime`으로 자동 변환될 수 있었다.
- 개인 복사본의 `data-contract.ps1` 날짜 검사가 정상 ISO 문자열과 변환된 날짜 객체를 모두 허용하도록 호환 처리했다.
- 수정 후 동일한 50,000건 전체 검사를 다시 실행해 PASS를 확인했다.

## 현재 데이터의 한계

- 기본 생성기는 `technology`와 `version`처럼 서로 종속된 후보를 독립적으로 선택하므로 일부 조합이 현실과 다를 수 있다.
- `error_message`, `error_category`, `cause`, `solution`도 독립 후보라 의미가 완전히 일치하지 않는 문서가 생길 수 있다.
- 현재 고정 대표 문서는 0건이다. 검색 품질 테스트 전에는 질문별 포함·경계·제외 대표 문서를 추가해야 한다.
