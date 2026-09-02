# 4교시 실습 — 정확 조건과 경계

## (공통) 문제 1 — 제공 코드로 세 filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
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

- `hits.total.value`: 380 (`relation: eq`)
- 확인한 문서 ID 3개: `P-00025`, `P-00129`, `P-00185`
- 각 문서의 category / in_stock / price:
  - `P-00025`: `전자기기` / `true` / `59400`
  - `P-00129`: `전자기기` / `true` / `53800`
  - `P-00185`: `전자기기` / `true` / `161600`
- 조건을 위반한 문서가 있는가: 없음. 확인한 세 문서 모두 category가 `전자기기`이고, `in_stock`이 `true`이며, price가 50000 이상 200000 이하임.

## (공통) 문제 2 — 경계 포함 범위 직접 구현

`products`에서 category가 `전자기기`이고 가격이 50,000원 이상 200,000원 이하인 상품을 검색하세요. 최대 10건을 반환하고 `product_id`, `name`, `category`, `price`만 표시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "category",
    "price"
  ],
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": "전자기기"
          }
        },
        {
          "range": {
            "price": {
              "gte": 50000,
              "lte": 200000
            }
          }
        }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 440 (`relation: eq`)
- 최소·최대 price: 반환된 10건 기준 최소 `53800`(`P-00129`), 최대 `199300`(`P-00457`)
- 50,000 또는 200,000 경계 문서 존재 여부와 ID: 존재하지 않음. 두 경계값을 별도로 정확 검색한 결과가 0건이었음.

## (공통) 문제 3 — 경계 제외 범위 직접 구현

문제 2에서 다른 조건은 모두 그대로 유지하고 가격 조건만 50,000원 초과 200,000원 미만으로 바꾸세요. 한 요소만 변경해야 합니다.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "category",
    "price"
  ],
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": "전자기기"
          }
        },
        {
          "range": {
            "price": {
              "gt": 50000,
              "lt": 200000
            }
          }
        }
      ]
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: 440 / 440
- 빠진 경계 문서 ID: 없음
- 경계 문서가 없어 결과가 같다면 확인한 근거: category가 `전자기기`이면서 price가 정확히 50000 또는 200000인 문서를 별도로 검색했지만 0건이었음. 제외되는 경계 문서가 없어 두 요청의 `hits.total.value`가 동일하게 440으로 확인됨.

## (개인) 문제 4 — 자기 정확 조건 2개

자기 데이터에서 정확 조건으로 사용할 field 2개를 선택해 두 조건을 모두 만족하는 검색을 구현하세요.

### 역할·검증 기준

- keyword·boolean 등 실제 mapping type에 적합해야 합니다.
- 실행 전 포함 예상 문서 1개와 제외 예상 문서 1개를 정합니다.
- 실행 후 `_source`로 판정합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "_source": [
    "case_id",
    "title",
    "error_category",
    "verified"
  ],
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "error_category": "dependency"
          }
        },
        {
          "term": {
            "verified": true
          }
        }
      ]
    }
  }
}
```

- field·type·값 2개:
  - `error_category` / `keyword` / `dependency`
  - `verified` / `boolean` / `true`
- 기대 ID / 제외 ID: 포함 예상 `DEVFIX-0003` / 제외 예상 `DEVFIX-0002`
- 실제 결과와 판정: 총 6305건이 두 조건에 일치함. 포함 예상 문서인 `DEVFIX-0003`은 결과에 포함됐고 제외 예상 문서인 `DEVFIX-0002`는 포함되지 않았음. 확인한 상위 5개 문서의 `error_category`가 모두 `dependency`이고 `verified`가 모두 `true`이므로 통과로 판정함.

## (개인) 문제 5 — 자기 범위와 경계 실험

자기 데이터의 numeric 또는 date field를 선택해 포함 경계와 제외 경계 요청을 각각 구현하세요.

### 역할·검증 기준

- 실제 데이터의 최소·최대 또는 의미 있는 경계값을 먼저 확인합니다.
- `gte/lte`와 `gt/lt` 외 조건은 동일하게 유지합니다.
- 경계 문서가 없으면 fixture 설계 또는 부재 근거를 기록합니다.

### API와 결과 입력

```http
# 포함 경계 요청
GET /devfix-cases/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "case_id",
    "title",
    "resolution_minutes"
  ],
  "query": {
    "range": {
      "resolution_minutes": {
        "gte": 60,
        "lte": 120
      }
    }
  },
  "sort": [
    { "resolution_minutes": "asc" },
    { "case_id": "asc" }
  ]
}

# 제외 경계 요청
GET /devfix-cases/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "case_id",
    "title",
    "resolution_minutes"
  ],
  "query": {
    "range": {
      "resolution_minutes": {
        "gt": 60,
        "lt": 120
      }
    }
  },
  "sort": [
    { "resolution_minutes": "asc" },
    { "case_id": "asc" }
  ]
}
```

- field / type / 경계값: `resolution_minutes` / `integer` / `60`, `120`
- 포함 요청 total / 제외 요청 total: 12979 (`relation: eq`) / 12549 (`relation: eq`)
- 달라진 문서 ID: 60분 경계: `DEVFIX-0280`, `DEVFIX-0985`, `DEVFIX-10265` 등, 120분 경계: `DEVFIX-0013`, `DEVFIX-0254`, `DEVFIX-0881` 등
- 경계 판정: `gte: 60`, `lte: 120`인 포함 요청은 60분과 120분 문서를 포함해 총 12979건을 반환함. `gt: 60`, `lt: 120`인 제외 요청은 두 경계값을 제외해 총 12549건을 반환함. 두 결과의 차이는 430건이며, 별도의 경계 확인 요청에서 `resolution_minutes`가 정확히 60 또는 120인 문서도 430건으로 확인함. 따라서 경계 문서가 제외되어 결과 차이가 발생한 것으로 판정함.
