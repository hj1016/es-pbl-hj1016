# 3교시 실습 — 전문 검색 확장

## (공통) 문제 1 — 제공 코드로 여러 field 검색

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name", "description"]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 505 (`relation: eq`)
- 상위 3개 ID·name:
  - `P-00241`: `SoundLab 프리미엄 무선 이어폰`
  - `P-00305`: `Auralis 실속형 무선 이어폰`
  - `P-00529`: `NeoTech 스마트 무선 이어폰`
- 각 문서가 name·description 중 어디에서 의도와 연결되는가: 상위 3개 모두 `name`에 `무선 이어폰`이 직접 포함되어 검색 의도와 연결된다. `description`은 일반적인 상품 설명이며 검색어와 직접 연결되지 않는다.
- 상위 3개 관련/보류/무관 판정: 세 문서 모두 상품명에 `무선 이어폰`이 들어 있으므로 모두 관련으로 판정한다.

## (공통) 문제 2 — field boost 직접 구현

문제 1과 같은 조건을 유지하되 `name` 일치를 `description`보다 3배 중요하게 보는 Search API를 작성하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "무선 이어폰",
      "fields": ["name^3", "description"]
    }
  }
}
```

### 비교 결과

- 변경 전 상위 3개 ID: `P-00241`, `P-00305`, `P-00529`
- 변경 후 상위 3개 ID: `P-00241`, `P-00305`, `P-00529`
- 순위가 달라진 문서와 이유: 순위가 달라진 문서는 없다. 상위 문서들이 모두 `name`에서 같은 검색어를 같은 형태로 만족해 boost 적용 전후의 상대적인 순위가 유지됐다. 다만 상위 문서의 `_score`는 약 `6.7587`에서 `20.2762`로 증가했다.
- boost가 사용자 의도에 유리했는가: 보류로 판정한다. 상품명 일치를 더 중요하게 보는 설계 방향은 사용자 의도에 맞지만, 실제 상위 결과와 순위가 바뀌지 않아 이번 데이터에서는 검색 품질 개선을 확인하지 못했다.

## (공통) 문제 3 — 구문 검색 직접 구현

`products` index의 `name`에서 `무선 이어폰`이라는 단어 순서와 인접성을 중요하게 검색하세요. `slop`은 0, 최대 5건으로 구현하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match_phrase": {
      "name": {
        "query": "무선 이어폰",
        "slop": 0
      }
    }
  }
}
```

### 결과 입력

- `hits.total.value`: 249 (`relation: eq`)
- 상위 문서 ID·name:
  - `P-00241`: `SoundLab 프리미엄 무선 이어폰`
  - `P-00305`: `Auralis 실속형 무선 이어폰`
  - `P-00529`: `NeoTech 스마트 무선 이어폰`
  - `P-00617`: `NeoTech 스마트 무선 이어폰`
  - `P-00777`: `NeoTech 프리미엄 무선 이어폰`
- 문제 1보다 결과가 같거나 줄어든 이유: 문제 1의 `multi_match`는 분석된 검색어 token 중 하나 이상이 일치하는 문서도 찾을 수 있지만, `match_phrase`와 `slop: 0`은 `무선` 다음에 `이어폰`이 같은 순서로 바로 인접한 문서만 찾기 때문에 505건에서 249건으로 줄었다.
- 구문 의도에 맞지 않는 문서가 있는가: 상위 5개 상품명에 모두 `무선 이어폰` 구문이 같은 순서로 인접해 있으므로 구문 의도에 맞지 않는 문서는 없다.

## (개인) 문제 4 — 여러 text field 검색

자기 프로젝트에서 같은 사용자 검색어가 적용될 수 있는 text field 2개 이상을 선택해 전문 검색을 구현하세요.

### 역할·검증 기준

- 각 field의 서비스 역할을 설명합니다.
- 상위 3개 문서를 사람이 평가합니다.
- 한 field만 필요한 도메인이라면 `match`를 선택하고 그 이유를 적어도 됩니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "_source": [
    "case_id",
    "title",
    "error_message",
    "symptoms"
  ],
  "query": {
    "multi_match": {
      "query": "Docker unhealthy",
      "fields": ["title", "error_message", "symptoms"]
    }
  }
}
```

- 사용자 질문·검색어: Docker에서 발생한 unhealthy 오류 해결 사례를 찾아줘 / `Docker unhealthy`
- 선택 field와 역할:
  - `title`: 기술 환경과 오류명이 요약된 검색 결과 제목 역할
  - `error_message`: 실제 오류 문자열을 검색하는 역할
  - `symptoms`: 사용자가 겪은 증상 설명을 검색하는 역할
- 상위 3개 판정:
  - `DEVFIX-0002`: 관련. 제목에 Docker와 unhealthy가 모두 있고 실제 `error_message`도 `unhealthy`이다.
  - `DEVFIX-0039`: 관련. Docker 환경의 unhealthy 오류 해결 사례로 검색 의도를 모두 만족한다.
  - `DEVFIX-0069`: 관련. 제목과 오류 메시지에서 Docker와 unhealthy 의도가 확인된다.
- query 선택 근거: 같은 사용자 검색어가 여러 `text` field에 나타날 수 있으므로 한 요청에서 `title`, `error_message`, `symptoms`를 함께 전문 검색하는 `multi_match`를 선택했다.

## (개인) 문제 5 — boost 또는 phrase 가설 검증

자기 검색에서 field boost 또는 phrase 중 하나를 선택해 기본 요청과 비교하세요.

### 역할·검증 기준

- 같은 index·데이터·검색어·size를 유지합니다.
- 한 요소만 변경합니다.
- 결과가 바뀌지 않아도 실제 결과대로 기록합니다.

### API와 결과 입력

```http
GET /devfix-cases/_search
{
  "size": 5,
  "_source": [
    "case_id",
    "title",
    "error_message",
    "symptoms"
  ],
  "query": {
    "multi_match": {
      "query": "Docker unhealthy",
      "fields": ["title^3", "error_message", "symptoms"]
    }
  }
}
```

- 선택한 가설: 검색 결과 제목인 `title`에서 검색어가 일치하는 문서를 다른 field 일치보다 3배 중요하게 평가하면 더 관련 있는 사례가 상위에 올 것이라고 가정했다.
- 변경 전·후 상위 3개:
  - 변경 전: `DEVFIX-0002`, `DEVFIX-0039`, `DEVFIX-0069`
  - 변경 후: `DEVFIX-0002`, `DEVFIX-0039`, `DEVFIX-0069`
- 개선/보류/악화 판정: 보류. boost 적용 후에도 상위 3개 문서와 순서는 바뀌지 않았다.
- 판정 근거: 상위 문서들이 모두 `title`에서 `Docker unhealthy`를 동일하게 만족해 상대적인 순위 변화가 없었다. `_score`는 약 `3.3822`에서 `10.1466`으로 증가했지만 실제 상위 결과가 달라지지 않았으므로 검색 품질이 개선됐다고 단정할 수 없다.
