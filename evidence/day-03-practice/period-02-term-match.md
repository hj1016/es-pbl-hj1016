# 2교시 실습 — term과 match

## (공통) 문제 1 — 제공 코드로 정확 조건 확인

```http
GET /products/_search
{
  "size": 5,
  "query": { "term": { "category": "전자기기" } }
}
```

### 결과 입력

- `hits.total.value`: 1250
- 상위 3개 문서 ID: `P-00009`, `P-00025`, `P-00081`
- 상위 3개 문서의 category: 전자기기, 전자기기, 전자기기
- 모든 확인 문서가 정확 조건을 만족하는가: 반환된 카테고리가 모두 전자기기라 만족함
- `term`을 선택한 mapping 근거: `category`는 `keyword` 타입으로, 분석되지 않은 원래 값의 정확 일치 검색에 사용되는 field이므로 `term` query가 적합함.

## (공통) 문제 2 — text 전문 검색 직접 구현

`products` index에서 상품명 `name`에 `무선`이라는 검색 의도가 있는 문서를 찾으세요. text 전문 검색에 적합한 query를 선택해 최대 5건을 반환하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match": {
      "name": "무선"
    }
  }
}
```

### 결과 입력

- 선택한 query와 이유: `match` query를 선택함. `name`은 `text` 타입이고, `match`는 입력한 검색어를 analyzer로 분석한 뒤 분석된 token을 기준으로 전문 검색을 하기 때문에 선택함.
- `hits.total.value`: 505 (`relation: eq`)
- 상위 3개 ID·name: "_id": "P-00025", "name": "MobiCore 컴팩트 무선 이어폰" / "_id": "P-00042", "name": "CleanMate 실속형 무선 청소기" / "_id": "P-00129", "name": "Auralis 스마트 무선 이어폰"

## (공통) 문제 3 — 부적절한 조합 비교

같은 `name` field와 `무선` 검색어에 `term` query를 사용한 API를 직접 작성하세요. 문제 2와 결과를 비교하고, 차이를 mapping 또는 분석된 token 관점에서 설명하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "term": {
      "name": "무선"
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 505/505
- 공통으로 나온 문서 ID: `P-00025`, `P-00042`, `P-00129`, `P-00153`, `P-00209`
- 달라진 이유: 결과가 같다. `match`는 검색어를 분석한 뒤 `무선` token으로 검색했고, `term`은 입력값을 분석하지 않았지만 입력값 자체가 이미 `무선` token과 같아서 동일한 결과가 나왔다.
- `term`은 text에서 항상 0건인가? 실제 근거: 항상 0건은 아님. name text field에 `term` query로 무선 검색하면 505건이 반환된다.

## (개인) 문제 4 — 자기 정확 조건 검색

자기 mapping에서 값 전체가 정확히 일치해야 하는 `keyword` 또는 `boolean` field 하나를 선택해 정확 조건 검색을 구현하세요.

### 역할·검증 기준

- 실제 존재하는 field와 값을 사용합니다.
- 반환 문서의 `_source`에서 조건을 직접 확인합니다.
- 왜 전문 검색이 아니라 정확 비교인지 설명합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "_source": [
    "case_id",
    "title",
    "error_category"
  ],
  "query": {
    "term": {
      "error_category": "authentication"
    }
  }
}
```

- field / type / 값: `error_category` / `keyword` / `authentication`
- 사용자 질문: 인증 오류에 해당하는 개발 오류 해결 사례를 찾아줘
- 상위 3개 ID와 실제 값: `DEVFIX-0001`: `authentication`, `DEVFIX-0002`: `authentication`, `DEVFIX-0004`: `authentication`
- 통과/실패와 근거: 통과. 상위 3개 문서의 `error_category`가 모두 `authentication`으로 일치했다. `error_category`는 분석되지 않은 전체 값을 비교하는 `keyword` field이므로 전문 검색이 아닌 `term` 정확 조건 검색이 적합하다.

## (개인) 문제 5 — 자기 전문 검색

자기 mapping의 `text` field 하나와 사용자가 입력할 검색어를 정해 전문 검색 API를 구현하세요.

### 역할·검증 기준

- field가 실제 `text`인지 mapping으로 확인합니다.
- 상위 3개 결과를 관련/보류/무관으로 판정합니다.
- 정확 조건 문제와 query 선택 이유가 달라야 합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "_source": [
    "case_id",
    "title",
    "technology",
    "error_message"
  ],
  "query": {
    "match": {
      "title": "Docker unhealthy"
    }
  }
}
```

- field / type / 검색어: `title` / `text` / `Docker unhealthy`
- 상위 3개 ID: `DEVFIX-0002`, `DEVFIX-0039`, `DEVFIX-0069`
- 관련/보류/무관과 이유: `DEVFIX-0002`: 관련. technology가 Docker이고 error_message가 unhealthy인데 제목에 모두 포함됨, `DEVFIX-0039`: 관련. Docker 환경에서 발생한 unhealthy 오류 해결 사례로 검색 의도를 모두 만족함, `DEVFIX-0069`: 관련. Docker와 unhealthy가 제목과 실제 field 값에서 모두 확인됨
- 완료 판정: 완료. `text` field인 `title`에 `match` query를 사용했고, 상위 3개 모두 `Docker unhealthy` 검색 의도와 관련 있는 것으로 확인됐다.
