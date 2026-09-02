# 1교시 실습 — Search API 기본

## (공통) 문제 1 — 제공 코드 실행·응답 읽기

다음 요청을 실행하세요.

```http
GET /products/_search
{
  "size": 5,
  "query": { "match_all": {} }
}
```

### 결과 입력

- HTTP 성공 여부: 성공
- `hits.total.value`: 10000
- `hits.hits`에 반환된 문서 수: 5
- 첫 번째 문서의 `_id`: P-00003
- 첫 번째 문서의 `_source` field 3개: `product_id`, `name`, `price`
- `hits.total.value`와 반환 문서 수가 다를 수 있는 이유: 요청 시 "size"를 5로 뒀기 때문에 최대 문서 수가 5개라서 끊길 수 있음.

## (공통) 문제 2 — 반환 개수와 field 직접 구현

`products` index의 전체 문서 중 최대 3건만 반환하고, `_source`에는 `product_id`, `name`, `price`, `in_stock`만 포함하는 Search API를 작성하고 실행하세요.

### API 전체 입력

```http
GET /products/_search
{
    "size": 3,
    "_source": [
        "product_id",
        "name",
        "price",
        "in_stock"
    ],
    "query": {
        "match_all": {}
    }
}
```

### 결과 입력

- 반환 문서 수: 3
- `_source`에 요구하지 않은 field가 포함됐는가: 포함되지 않았음. `product_id`, `name`, `price`, `in_stock`만 반환됨.
- 검증한 문서 ID: `P-00003`, `P-00004`, `P-00008`

## (공통) 문제 3 — 정렬이 포함된 전체 조회 구현

`products` index의 전체 문서 중 최대 10건을 `price`가 낮은 순서로 반환하세요. `_source`에는 `product_id`, `name`, `price`만 포함하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "price"
  ],
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "price": {
        "order": "asc"
      }
    }
  ]
}
```

### 결과 입력

- 첫 3개 문서의 ID와 price: `P-00431`: 5900, `P-06599`: 5900, `P-06479`: 5900
- 오름차순 여부: 오름차순임.
- 두 문서의 price가 같을 때 순서가 고정된다고 말할 수 있는가? 근거: 고정되지 않음. 정렬 기준으로 price만 지정해서 가격이 같은 문서끼리는 순서를 정렬하는 보조 결정 기준이 없음.

## (개인) 문제 4 — 자기 index의 첫 Search API

자기 index의 전체 문서 중 최대 5건을 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 실제 자기 index 이름을 사용합니다.
- `_count`와 `hits.total.value`를 비교합니다.
- `size`와 전체 일치 문서 수를 구분해 설명합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
    "size": 5,
    "query": {
        "match_all": {}
    }
}
```

- 자기 index: devfix-cases
- `_count`: 50000
- `hits.total.value`: 10000 ("relation": "gte")
- 반환 문서 수: 5
- 판정과 근거: 정상. _count 결과로 devfix-cases에 50000건 저장되어있는 것을 확인함. Search API의 hits.total은 기본적으로 10000건까지만 정확하게 집계하므로 value가 10000이고 relation이 gte로 표시됨. 전체 결과가 10000건 이상이기 때문. 또한 size는 응답에 반환할 최대 문서수라서 hits.hits에는 5건이 반환됨.

## (개인) 문제 5 — 결과 카드 field 설계

자기 서비스에서 검색 결과 카드 한 개를 보여 준다고 가정하세요. 사용자가 클릭 여부를 결정하는 데 필요한 field 3~5개만 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 선택한 field가 자기 mapping과 실제 문서에 존재해야 합니다.
- 식별자, 제목 역할, 판단용 정보가 포함되어야 합니다.
- 불필요한 field를 하나 이상 제외하고 이유를 설명합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 3,
  "_source": [
    "case_id",
    "title",
    "technology",
    "verified",
    "helpful_count"
  ],
  "query": {
    "match_all": {}
  }
}
```

- 포함한 field와 이유: `case_id`: 사례를 구분하는 고유 식별자라서, `title`: 사용자가 어떤 오류의 해결 사례인지 확인할 수 있어서, `technology`: 기술 환경이 관련있는 사례인지 판단하는 요소, `verified`: 검증된 해결 사례인지 판단, `helpful_count`: 다른 사용자에게 도움이 된 정도를 판단할 수 있음
- 제외한 field와 이유: `solution`은 내용이 길어서 검색 결과 카드에선 안 나와도 된다고 생각했다. 카드 클릭 후 상세 화면에서 보여주는 게 적절하다.
- 실제 반환 문서 ID: `DEVFIX-0001`, `DEVFIX-0002`, `DEVFIX-0003`
- 완료 판정: 완료됨. 3건이 정상 반환됐고 각 문서 _source에 선택한 5개 필드만 포함됨. 불필요해서 제외한 필드는 제외됨.
