# msk-monitoring-docker-compose
## 1. 개요
본 문서는 EC2 환경에서 Docker Compose를 활용하여 Prometheus, Thanos Sidecar 및 Burrow를 구축하는 방법을 설명합니다.

## 2. 사전 준비
### 2.1 시스템 요구 사항
- OS: Amazon Linux 2 또는 Ubuntu 20.04 이상
- Docker 및 Docker Compose 설치
- EC2 보안 그룹에서 다음 포트 허용
  - Prometheus: `9090`
  - Thanos Sidecar: `10901`, `10902`
  - Burrow: `8000`

### 2.2 패키지 설치
```sh
# Docker 설치
sudo yum install -y docker
sudo systemctl enable docker --now

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 3. 폴더 구조
```
MSK-MONITORING/
│── templates/                # 설정 템플릿 폴더
│   ├── burrow.tmpl.toml       # Burrow 설정 템플릿
│   ├── prometheus.tmpl.yaml   # Prometheus 설정 템플릿
│   ├── targets.tmpl.json      # Prometheus 타겟 설정 템플릿
│── deploy.sh                  # 배포 스크립트
│── docker-compose.yaml        # Docker Compose 설정 파일
│── Makefile                   # 설정 렌더링 및 빌드 관리
│── README.md                  # 프로젝트 문서
```

## 4. 주요 구성 요소

### 4.1 Burrow
- Kafka Consumer 상태를 모니터링하는 도구
- `burrow.tmpl.toml` 파일을 기반으로 환경 변수를 대체하여 설정
- SASL/TLS 인증을 사용하여 MSK에 연결
- HTTP 서버를 통해 상태 제공

### 4.2 Prometheus
- Kafka 및 Burrow 메트릭 수집
- `prometheus.tmpl.yaml`을 기반으로 환경 변수 대체 후 설정
- `targets.tmpl.json`을 통해 JMX 및 Node Exporter 메트릭 수집

### 4.3 Docker Compose
- `docker-compose.yaml`을 사용하여 Burrow, Prometheus, Thanos Sidecar 컨테이너 실행
- 컨테이너 간 네트워크를 구성하여 원활한 통신 지원

### 4.4 Makefile
- `make render`: 환경 변수를 반영하여 설정 파일을 생성 (`generated/` 디렉토리)

### 4.5 환경 변수 관리
환경 변수는 아래 example 처럼 docker-compose와 같은 디렉토리에 `.env` 형태로 관리하세요
```env
PROM_CLUSTER={your-cluster-name}
PROMETHEUS_PORT=9090
BURROW_PORT=8000

ZOOKEEPER_HOST_1={zookeeper1_endpoint}
ZOOKEEPER_HOST_2={zookeeper2_endpoint}
ZOOKEEPER_HOST_3={zookeeper3_endpoint}

BROKER_HOST_1={broker1_endpoint}
BROKER_HOST_2={broker2_endpoint}
BROKER_HOST_3={broker3_endpoint}

BURROW_USERNAME={user}
BURROW_PASSWORD={password}
```

## 5. 설치 및 실행 방법
### 5.1 프로젝트 클론
```sh
git clone https://github.com/dings-things/msk-monitoring-docker-compose.git
cd msk-monitoring-docker-compose
```

### 5.2 환경 변수 설정
`.env` 파일을 생성

### 5.3 배포 스크립트 실행
```sh
chmod +x deploy.sh
./deploy.sh
```

### 5.4 개별 실행 (수동 실행)
```sh
make render
docker compose up -d
```

## 6. Prometheus 모니터링 확인
Prometheus Web UI에서 수집된 메트릭을 확인할 수 있습니다.
```sh
http://localhost:9090
```

## 7. Burrow Consumer Group 모니터링
Burrow는 Consumer Group의 Lag을 모니터링하는 데 사용됩니다. Prometheus에서 `burrow_kafka_consumer_lag_total` 지표를 확인하세요.

Burrow HTTP 서버에서 Consumer 상태를 확인할 수 있습니다.
```sh
http://localhost:8000/v3/kafka/custom-burrow/consumer
```

## 8. 서비스 중지
```sh
docker-compose down
```

## 9. 참고
- Burrow 공식 문서: https://github.com/linkedin/Burrow
- Prometheus 공식 문서: https://prometheus.io/docs/

