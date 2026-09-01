# Day 2 데이터 준비 결과

> 예시 문장을 복사하지 않고 DevFix의 실제 실행 결과를 작성한다.
> 실행하지 않은 항목은 완료로 표시하지 않는다.

## 1. Index와 문서

- Index 이름: `devfix-cases`
- 문서 한 건의 의미: 오류 메시지, 실행 환경, 발생 원인, 해결 방법과 검증 결과를 담은 개발 오류 해결 사례 1건
- 실제 색인 건수: 50,000건
- Mapping의 `dynamic` 설정: `strict`

## 2. 최종 Field

| Field | Type | 검색에서 사용할 목적 |
|---|---|---|
| `case_id` | `keyword` | 사례 업무 ID의 정확 비교와 결과 표시 |
| `title` | `text` | 오류 사례 제목의 전문 검색과 결과 표시 |
| `symptoms` | `text` | 사용자가 설명한 증상의 전문 검색 |
| `error_message` | `text` + `keyword` multi-field | 오류 문자열의 전문 검색과 전체 값 정확 비교 |
| `technology` | `keyword` 배열 | 기술별 filter·집계와 결과 표시 |
| `version` | `keyword` | 기술 버전의 정확 조건 |
| `os` | `keyword` | 운영체제별 filter·집계 |
| `error_category` | `keyword` | 오류 유형별 filter·집계 |
| `cause` | `text` | 발생 원인 설명의 전문 검색과 결과 표시 |
| `solution` | `text` | 해결 방법의 전문 검색과 결과 표시 |
| `verified` | `boolean` | 검증 완료 여부 filter·집계 |
| `resolution_minutes` | `integer` | 해결 시간의 범위 조건·정렬·통계 집계 |
| `helpful_count` | `integer` | 도움됨 횟수의 범위 조건·정렬·통계 집계 |
| `created_at` | `date` | 등록 기간 filter와 최신순 정렬 |

## 3. 대량 데이터 생성·색인 결과

- 생성 건수:
- 로컬 검증 결과:
- Bulk 색인 결과:
- ES 실제 `_count`:
- 분류·숫자·boolean 분포 확인 결과:

## 4. Day 3 연결

- 검색 질문 기준: `docs/data-model.md`의 사용자 질문 3개

## 5. 결과 파일 위치

- Mapping:
- 실행 요청:
- 대표 문서:
- 데이터 생성 설정:
- 생성 표본:
- 생성 요약:

## 6. Pipeline 적용 판단

- 적용 / 미적용 / 보류:
- 판단 이유:

## 7. 미완료·오류

- 없음 또는 현재 상태:
- 다음에 할 작업:
