# 5교시 실습 — bool 검색

## (공통) 문제 1 — 제공 코드로 must·filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 74
- 상위 3개 ID·name:
  1. `P-00025` · `MobiCore 컴팩트 무선 이어폰`
  2. `P-00129` · `Auralis 스마트 무선 이어폰`
  3. `P-00369` · `SoundLab 데일리 무선 이어폰`
- 세 filter의 실제 값: 상위 3건 모두 `category=전자기기`, `in_stock=true`이며, `price`는 각각 `59,400`, `53,800`, `162,800`으로 `50,000~200,000` 범위에 있다.
- must와 filter의 역할 차이: `must`는 `name`에 `무선`이 검색되어야 하는 관련도 검색 조건이며 `_score` 계산에 참여한다. `filter`는 category·재고·가격을 정확히 제한하며 `_score`는 계산하지 않는다.

## (공통) 문제 2 — 조건 제거 실험 직접 구현

문제 1의 요청에서 `in_stock` filter만 제거한 API를 작성하세요. 다른 조건은 바꾸지 마세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

- 변경 전 total / 변경 후 total: `74` / `83`
- 새로 포함된 문서 ID·in_stock: `P-00457`·`false`, `P-00521`·`false`, `P-04393`·`false`
- 변화가 없다면 데이터 근거: 변화가 있다. `in_stock=false`이면서 나머지 조건을 만족하는 문서가 `9건`이었고, total도 `74→83`으로 `9건` 증가했다.
- 제거한 조건의 역할: `in_stock=true` filter는 나머지 조건을 만족해도 품절인 상품을 결과에서 제외한다.

## (공통) 문제 3 — should 조건 직접 구현

category가 `전자기기`인 문서 중 `name`에 `무선`이 있거나 `in_stock=true`인 조건을 최소 하나 만족하도록 bool API를 작성하세요. `minimum_should_match`를 명시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } }
      ],
      "should": [
        { "match": { "name": "무선" } },
        { "term": { "in_stock": true } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

### 결과 입력

- `hits.total.value`: `1,097`
- 무선이지만 품절인 문서 존재 여부: 있음. 별도 확인 결과 `32건`이며, 예시는 `P-00457`(`MobiCore 데일리 무선 이어폰`, `in_stock=false`)이다.
- 무선이 아니지만 재고가 있는 문서 존재 여부: 있음. 별도 확인 결과 `848건`이며, 예시는 `P-00009`(`NeoTech 데일리 기계식 키보드`, `in_stock=true`)이다.
- should 조건 판정: category가 `전자기기`인 문서에서 `name`의 `무선` 또는 `in_stock=true` 중 적어도 하나를 만족한 문서가 반환됐다. `minimum_should_match: 1`이 의도대로 적용되었다.

## (개인) 문제 4 — 자기 bool 검색

자기 사용자 질문 하나를 검색 의도와 정확 조건으로 분해해 bool 요청을 구현하세요.

### 역할·검증 기준

- must 0~1개, filter 2개 이상을 사용합니다.
- 각 field와 query 선택 이유를 mapping type으로 설명합니다.
- 반환 문서 3개 이상을 실제 값으로 검증합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "case_id",
    "title",
    "technology",
    "verified",
    "resolution_minutes"
  ],
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "unhealthy" } }
      ],
      "filter": [
        { "term": { "technology": "Docker" } },
        { "term": { "verified": true } },
        { "range": { "resolution_minutes": { "lte": 120 } } }
      ]
    }
  }
}
```

- 사용자 질문: Docker에서 발생한 `unhealthy` 오류 중 검증이 완료되었고 120분 이내에 해결된 사례를 찾아줘.
- must와 이유: `title` / `match` / `unhealthy`. `title`은 분석되는 `text` type이므로 오류명을 전문 검색하고 관련도 점수를 계산하기 위해 `must`에 두었다.
- filter 2개와 이유: 총 3개를 사용했다. `technology=Docker`는 `keyword` 정확 조건, `verified=true`는 `boolean` 정확 조건, `resolution_minutes<=120`은 `integer` 범위 조건이다. 관련도보다 조건 충족 여부가 중요하여 `filter`로 사용했다.
- 실제 검증 결과: 조건에 일치한 문서는 `744건`이다. 상위 3건은 `DEVFIX-0069`(`Docker`, `true`, `21분`), `DEVFIX-0250`(`Docker`, `true`, `53분`), `DEVFIX-0717`(`Docker`, `true`, `108분`)이다. 세 문서 모두 title에 `unhealthy`가 있고 세 filter를 모두 만족한다.

## (개인) 문제 5 — 조건 역할 검증

개인 문제 4에서 filter 하나를 제거하고 전후 결과를 비교하세요. 추가로 원래 조건에서 제외되어야 하는 문서 1개를 독립 요청으로 확인하세요.

### 역할·검증 기준

- 한 번에 filter 하나만 제거합니다.
- 새로 포함된 문서의 실제 값을 확인합니다.
- 제외 문서는 원래 bool 결과에 포함되지 않아야 합니다.

### API와 결과 입력

```http
# `verified=true` filter를 제거한 비교 요청
GET /devfix-cases/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "case_id",
    "title",
    "technology",
    "verified",
    "resolution_minutes"
  ],
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "unhealthy" } }
      ],
      "filter": [
        { "term": { "technology": "Docker" } },
        { "range": { "resolution_minutes": { "lte": 120 } } }
      ]
    }
  }
}

# 새로 포함된 문서를 ID로 독립 확인
GET /devfix-cases/_search
{
  "size": 1,
  "_source": [
    "case_id",
    "title",
    "technology",
    "verified",
    "resolution_minutes"
  ],
  "query": {
    "term": {
      "case_id": "DEVFIX-0077"
    }
  }
}
```

- 제거한 filter: `{ "term": { "verified": true } }`
- 전/후 total: `744` / `1,012` (`268건` 증가)
- 새로 포함된 ID와 값: `DEVFIX-0077`·`verified=false`·`38분`, `DEVFIX-0283`·`verified=false`·`8분`, `DEVFIX-0379`·`verified=false`·`95분`. 모두 `technology=Docker`이고 title에 `unhealthy`가 있으며 120분 이내이다.
- 제외 확인 ID와 근거: `DEVFIX-0077`을 `case_id` 정확 조건으로 독립 조회한 결과 `technology=["Docker"]`, title에 `unhealthy`, `resolution_minutes=38`이지만 `verified=false`였다. 따라서 원래 `verified=true` bool 결과에서는 제외되고 filter를 제거한 후에만 포함된다.
