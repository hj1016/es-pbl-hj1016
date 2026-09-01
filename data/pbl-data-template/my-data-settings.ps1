# 메모장에서 '=' 오른쪽 값과 field 규칙만 자신의 주제에 맞게 바꿉니다.
# 이 파일은 생성기가 읽는 PowerShell 변수 설정입니다. 제공된 형식을 유지하고 값과 규칙만 수정합니다.

$IndexName = 'devfix-cases'
$DocumentCount = 50000
$Seed = 20260901
$IdPrefix = 'DEVFIX'
$IdField = 'case_id'
$SampleCount = 30

# choice와 tags 규칙이 참조하는 도메인별 후보 목록입니다.
$Vocabularies = [ordered]@{
  technologies = @('Elasticsearch', 'Docker', 'Spring Boot', 'MySQL', 'Redis', 'Kibana')
  versions = @('9.5.0', '8.19.0', '3.5.0', '17', '28.3.3')
  operating_systems = @('macOS', 'Linux', 'Windows')
  error_categories = @('cluster_discovery', 'container_health', 'network_connection', 'configuration', 'authentication', 'dependency')
  error_messages = @('master_not_discovered_exception', 'unhealthy', 'Connection refused', 'index_not_found_exception', 'authentication failed', 'BeanCreationException')
  causes = @(
    '서비스 탐색 설정과 실제 실행 환경의 이름이 일치하지 않았다.',
    '필수 서비스가 준비되기 전에 연결을 시도했다.',
    '포트 또는 호스트 설정이 실제 실행 환경과 달랐다.',
    '환경 변수와 애플리케이션 설정값이 일치하지 않았다.',
    '필요한 권한 또는 인증 정보가 올바르게 전달되지 않았다.',
    '사용 중인 라이브러리와 실행 환경의 버전이 호환되지 않았다.'
  )
  solutions = @(
    '서비스 탐색 설정과 실행 환경의 이름을 일치시킨 뒤 다시 시작했다.',
    '의존 서비스의 상태를 확인하고 준비 완료 후 연결하도록 수정했다.',
    '포트와 호스트 설정을 확인하여 실제 접속 주소로 변경했다.',
    '환경 변수와 설정 파일의 값을 동일하게 맞춘 뒤 재실행했다.',
    '권한과 인증 정보를 다시 설정하고 접근 가능 여부를 확인했다.',
    '호환되는 버전 조합으로 변경한 뒤 동일한 절차로 재현하여 검증했다.'
  )
}

# 문서는 위에서 아래 순서로 만들어집니다.
# template는 앞에서 만든 field와 {{sequence}}을 사용할 수 있습니다.
$FieldRules = @(
  @{ Name = 'case_id'; Kind = 'id'; Digits = 4 }
  @{ Name = 'technology'; Kind = 'tags'; Source = 'technologies'; MinItems = 1; MaxItems = 2 }
  @{ Name = 'version'; Kind = 'choice'; Source = 'versions' }
  @{ Name = 'os'; Kind = 'choice'; Source = 'operating_systems' }
  @{ Name = 'error_category'; Kind = 'choice'; Source = 'error_categories' }
  @{ Name = 'error_message'; Kind = 'choice'; Source = 'error_messages' }
  @{ Name = 'title'; Kind = 'template'; Template = '{{technology}} 환경의 {{error_message}} 해결 사례 {{sequence}}' }
  @{ Name = 'symptoms'; Kind = 'template'; Template = '{{error_message}} 오류가 발생하여 서비스가 정상적으로 실행되지 않는다.' }
  @{ Name = 'cause'; Kind = 'choice'; Source = 'causes' }
  @{ Name = 'solution'; Kind = 'choice'; Source = 'solutions' }
  @{ Name = 'verified'; Kind = 'boolean'; TrueRatio = 0.75 }
  @{ Name = 'resolution_minutes'; Kind = 'integer'; Min = 5; Max = 240 }
  @{ Name = 'helpful_count'; Kind = 'integer'; Min = 0; Max = 200 }
  @{ Name = 'created_at'; Kind = 'date'; Start = '2025-01-01T00:00:00Z'; End = '2026-08-29T23:59:59Z' }
)
