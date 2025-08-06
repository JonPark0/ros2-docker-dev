# 🤖 ROS2 Docker 개발환경

[![ROS2](https://img.shields.io/badge/ROS2-Humble-blue)](https://docs.ros.org/en/humble/)
[![Docker](https://img.shields.io/badge/Docker-v20.10+-blue)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-green)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

크로스 플랫폼 GUI 지원을 포함한 완전한 ROS2 개발환경을 Docker로 구성한 프로젝트입니다.

## 주요 특징

- **크로스 플랫폼 지원**: Linux, Windows (WSL2), macOS
- **GUI 애플리케이션 지원**: RViz, Gazebo, rqt 도구들
- **자동 환경 설정**: 운영체제별 최적화된 설정
- **개발자 친화적**: 필수 도구들과 패키지 사전 설치
- **자동 환경 초기화**: 컨테이너 시작 시 ROS2 환경 자동 소싱
- **사용자 친화적 인터페이스**: 컬러풀한 터미널과 유용한 별칭들
- **모듈화된 구성**: 필요에 따라 서비스 선택 가능

## 포함된 구성요소

### ROS2 패키지
- **Core**: ROS2 Humble Desktop Full
- **Visualization**: RViz2, rqt 전체 도구 모음
- **Simulation**: Gazebo Classic & Ignition
- **Robotics**: MoveIt2, Navigation2, TF2
- **Development**: colcon, vcstool, rosdep

### 개발 도구
- **언어**: Python 3.10, C++17
- **에디터**: Vim, Nano
- **디버깅**: GDB, Valgrind
- **버전 관리**: Git
- **모니터링**: htop, tree

## 시스템 요구사항

### 공통 요구사항
- Docker Engine 20.10+
- Docker Compose v2.0+
- 최소 8GB RAM (권장: 16GB)
- 최소 20GB 디스크 공간

### 플랫폼별 요구사항

#### Linux
```bash
# Docker 설치
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker $USER
```

#### Windows
- Windows 10/11 (Build 19041+)
- WSL2 활성화
- Docker Desktop for Windows
- X11 서버 (VcXsrv 권장)

#### macOS
- macOS 10.15+
- Docker Desktop for Mac
- XQuartz

## 빠른 시작

### 1. Github에서 프로젝트 내려받기
```bash
git clone https://github.com/jonpark0/ros2-docker-dev
cd ros2-docker-dev
```

### 2. 설정 스크립트에 실행 권한 부여하기
```bash
chmod +x setup.sh
./setup.sh
```

### 3. 환경 변수 수정하기
```bash
# .env 파일을 확인하고 필요시 수정
nano .env
```

### 4. 도커 개발환경 시작하기
```bash
./start.sh
```

### 5. 컨테이너 접속하기
```bash
./connect.sh
```

## 프로젝트 구조와 파일 관리

### 디렉토리 구조

### Git 버전 관리
프로젝트에는 ROS2 개발환경에 최적화된 `.gitignore` 파일이 포함되어 있습니다:

```bash
# 주요 무시 대상들
.env                    # 실제 환경 설정 파일
workspace/build/        # ROS2 빌드 결과물
workspace/install/      # ROS2 설치 파일들
workspace/log/          # ROS2 로그 파일들
*.bag                   # ROS bag 파일들
.docker/               # Docker 캐시 파일들
```

### 환경 설정 파일 관리
```bash
# .env.example을 복사하여 개인 설정 생성
cp .env.example .env

# 팀 공유용 환경 설정
cp .env.example .env.team

# 개인별 환경 설정은 Git에서 제외됨
```

```
ros2-docker-dev/
├── docker-compose.yml    # Docker Compose 설정
├── .env.example          # 환경변수 템플릿
├── Dockerfile            # 커스텀 개발환경 (선택)
├── .gitignore            # Git 무시 파일 설정
├── setup.sh              # 자동 설정 스크립트
├── entrypoint.sh         # 컨테이너 진입점 스크립트
├── start.sh              # 환경 시작 스크립트
├── stop.sh               # 환경 중지 스크립트
├── connect.sh            # 컨테이너 접속 스크립트
├── workspace/            # ROS2 워크스페이스
│   └── src/             # ROS2 패키지 소스
├── config/               # 설정 파일들
│   └── ros2_bashrc      # ROS2 환경 설정
├── gazebo_models/        # Gazebo 모델들
└── logs/                 # 로그 파일들
```

## 사용 방법

### 컨테이너 접속 후 환경 확인
컨테이너에 접속하면 ROS2 환경이 자동으로 초기화됩니다:

```bash
🤖 ROS2 개발환경을 초기화합니다...
📦 ROS2 환경을 로드합니다...
✅ ROS2 환경이 준비되었습니다!
📋 ROS_DISTRO: humble
🌐 ROS_DOMAIN_ID: 0
💻 RMW_IMPLEMENTATION: rmw_fastrtps_cpp

[ROS2-humble] /workspace$ ros2 topic list
[ROS2-humble] /workspace$ ros2 node list
```

### 기본 ROS2 개발

```bash
# 컨테이너 접속
./connect.sh

# 새 패키지 생성
cd /workspace/src
ros2 pkg create --build-type ament_python my_robot_pkg

# 패키지 빌드
cd /workspace
colcon build --packages-select my_robot_pkg

# 환경 소싱
source install/setup.bash

# 노드 실행
ros2 run my_robot_pkg my_node
```

### GUI 애플리케이션 실행

```bash
# RViz 실행
rviz2

# rqt 도구들
rqt_graph
rqt_console
rqt_plot

# Gazebo 시뮬레이션
gazebo
```

### 축약된 명령어들
컨테이너 내에서는 아래와 같이 축약된 명령어들을 바로 사용할 수 있습니다:

```bash
# Colcon 빌드 별칭들
cb          # colcon build
cbs         # colcon build --symlink-install
cbp         # colcon build --packages-select
cbt         # colcon test
ctr         # colcon test-result

# 파일 시스템 별칭들
ll          # ls -alF
la          # ls -A
l           # ls -CF
```

### 멀티 터미널 작업

```bash
# 터미널 1: 퍼블리셔
./connect.sh
ros2 run demo_nodes_cpp talker

# 터미널 2: 서브스크라이버  
./connect.sh
ros2 run demo_nodes_py listener
```

## 시뮬레이션 환경

### Gazebo 시뮬레이션 시작
```bash
# 시뮬레이션 프로파일로 실행
docker compose --profile simulation up -d

# 컨테이너 접속
./connect.sh

# TurtleBot3 시뮬레이션
export TURTLEBOT3_MODEL=waffle
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```

### 로봇 모델 시각화
```bash
# URDF 모델 로드
ros2 launch robot_state_publisher robot_state_publisher.launch.py

# Joint State Publisher
ros2 run joint_state_publisher_gui joint_state_publisher_gui
```

## 환경 설정

### 주요 환경변수 (.env 파일)

```bash
# === 기본 설정 ===
CONTAINER_NAME=ros2-dev-container
ROS2_IMAGE=osrf/ros:humble-desktop-full

# === ROS2 설정 ===
ROS_DOMAIN_ID=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# === 사용자 설정 ===
USER_ID=1000
GROUP_ID=1000
USER_NAME=developer

# === 경로 설정 ===
WORKSPACE_PATH=./workspace
CONFIG_PATH=./config

# === 리소스 제한 ===
MEMORY_LIMIT=8G
CPU_LIMIT=4.0
```

### ROS2 도메인 설정
```bash
# 다른 ROS2 시스템과 격리
echo "ROS_DOMAIN_ID=42" >> .env

# DDS 구현체 변경
echo "RMW_IMPLEMENTATION=rmw_cyclonedx_cpp" >> .env
```

## 플랫폼별 설정

### Linux
```bash
# X11 디스플레이 접근 허용
xhost +local:docker

# GPU 접근 (NVIDIA)
# docker-compose.yml에서 NVIDIA runtime 활성화
```

### Windows (WSL2)
```bash
# VcXsrv 설치 및 설정
# 1. VcXsrv 다운로드: https://sourceforge.net/projects/vcxsrv/
# 2. 실행 시 "Disable access control" 체크
# 3. Windows 방화벽에서 VcXsrv 허용

# WSL2에서 Windows IP 확인
ip route show | grep default | awk '{print $3}'
```

### macOS
```bash
# XQuartz 설치
brew install --cask xquartz

# XQuartz 설정
# Preferences > Security > "Allow connections from network clients" 체크

# 네트워크 접근 허용
xhost +localhost
```

## 문제 해결

### 디스플레이 문제

**문제**: GUI 애플리케이션이 실행되지 않음
```bash
# 해결방법 1: X11 권한 확인
xhost +local:docker

# 해결방법 2: DISPLAY 환경변수 확인
echo $DISPLAY

# 해결방법 3: 컨테이너 내에서 테스트
docker compose exec ros2-dev xclock
```

**문제**: WSL2에서 디스플레이 연결 실패
```bash
# Windows IP 다시 확인
export DISPLAY=$(ip route show | grep default | awk '{print $3}'):0.0

# .env 파일 업데이트
sed -i "s/DISPLAY=.*/DISPLAY=$DISPLAY/" .env
```

### 권한 문제

**문제**: 파일 권한 오류
```bash
# 워크스페이스 소유권 변경
sudo chown -R $USER:$USER workspace/

# 사용자 ID 재설정
echo "USER_ID=$(id -u)" >> .env
echo "GROUP_ID=$(id -g)" >> .env
```

### 네트워크 문제

**문제**: ROS2 노드 간 통신 안됨
```bash
# ROS_DOMAIN_ID 확인
echo $ROS_DOMAIN_ID

# 멀티캐스트 확인
ros2 multicast receive
# 다른 터미널에서
ros2 multicast send
```

### ROS2 환경 문제

**문제**: 컨테이너 시작 후 ROS2 명령어가 인식되지 않음
```bash
# 해결방법 1: 수동으로 환경 소싱
source /opt/ros/humble/setup.bash

# 해결방법 2: 컨테이너 재시작
./stop.sh && ./start.sh

# 해결방법 3: entrypoint.sh 실행 권한 확인
chmod +x entrypoint.sh
```

### 메모리 부족

**문제**: 컨테이너 실행 중 메모리 부족
```bash
# 리소스 제한 조정 (.env 파일)
MEMORY_LIMIT=4G
CPU_LIMIT=2.0

# 불필요한 서비스 비활성화
docker compose down gazebo
```

## 고급 사용법

### 진입점 스크립트 커스터마이징

`entrypoint.sh`를 수정하여 컨테이너 시작 시 추가 설정을 적용할 수 있습니다:

```bash
# entrypoint.sh에 추가할 수 있는 내용들

# 1. 추가 ROS2 패키지 환경 소싱
if [ -f "/opt/moveit2/setup.bash" ]; then
    source /opt/moveit2/setup.bash
fi

# 2. 사용자 정의 환경변수 설정
export GAZEBO_MODEL_PATH="/workspace/gazebo_models:$GAZEBO_MODEL_PATH"
export RVIZ_CONFIG_PATH="/workspace/config/rviz"

# 3. 자동으로 특정 노드 실행
# ros2 run my_package my_node &
```

### 커스텀 Docker 이미지 빌드

```bash
# Dockerfile을 사용한 커스텀 빌드
docker compose -f docker-compose.yml -f docker-compose.override.yml build

# 특정 ROS2 배포판 사용
echo "ROS2_IMAGE=osrf/ros:iron-desktop-full" >> .env
```

### 멀티 로봇 시뮬레이션

```bash
# 여러 ROS_DOMAIN_ID로 분리
docker compose -p robot1 --env-file .env.robot1 up -d
docker compose -p robot2 --env-file .env.robot2 up -d
```

### CI/CD 통합

```bash
# GitHub Actions 예시
name: ROS2 CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and Test
        run: |
          ./setup.sh
          docker compose run --rm ros2-dev colcon test
```

### 파일 권한 및 버전 관리

**중요한 파일들의 권한 설정**:
```bash
# 실행 스크립트들 권한 확인
chmod +x setup.sh start.sh stop.sh connect.sh entrypoint.sh

# Git에서 실행 권한 유지
git update-index --chmod=+x setup.sh
git update-index --chmod=+x entrypoint.sh
```

**민감한 파일 관리**:
```bash
# .env 파일은 절대 커밋하지 마세요
echo ".env" >> .gitignore

# SSH 키나 인증서는 별도 관리
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```