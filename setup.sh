#!/bin/bash
# =============================================================================
# ROS2 Docker 개발환경 자동 설정 스크립트
# =============================================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 운영체제 감지
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 필요한 디렉토리 생성
create_directories() {
    log_info "필요한 디렉토리를 생성합니다..."
    
    mkdir -p workspace/src
    mkdir -p config
    mkdir -p gazebo_models
    mkdir -p logs
    
    log_success "디렉토리 생성 완료"
}

# .env 파일 설정
setup_env_file() {
    log_info ".env 파일을 설정합니다..."
    
    if [ ! -f .env ]; then
        cp .env.example .env
        log_success ".env 파일이 생성되었습니다"
    else
        log_warning ".env 파일이 이미 존재합니다"
    fi
    
    # 운영체제별 환경변수 설정
    OS=$(detect_os)
    case $OS in
        "linux")
            setup_linux_env
            ;;
        "wsl")
            setup_wsl_env
            ;;
        "macos")
            setup_macos_env
            ;;
        "windows")
            setup_windows_env
            ;;
        *)
            log_warning "알 수 없는 운영체제입니다. 수동으로 설정해주세요."
            ;;
    esac
}

# Linux 환경 설정
setup_linux_env() {
    log_info "Linux 환경을 설정합니다..."
    
    # X11 접근 허용 (간단한 방법)
    if command -v xhost >/dev/null 2>&1; then
        xhost +local:docker 2>/dev/null || log_warning "xhost 실행 실패 - GUI 애플리케이션이 작동하지 않을 수 있습니다"
        log_success "X11 접근 권한 설정 완료"
    else
        log_warning "xhost 명령어가 없습니다. X11 GUI가 작동하지 않을 수 있습니다"
    fi
    
    # 사용자 ID/GID 설정
    sed -i "s/USER_ID=.*/USER_ID=$(id -u)/" .env
    sed -i "s/GROUP_ID=.*/GROUP_ID=$(id -g)/" .env
    sed -i "s/USER_NAME=.*/USER_NAME=$USER/" .env
    
    # Docker에 X11 접근 허용
    xhost +local:docker 2>/dev/null || log_warning "xhost 명령어를 실행할 수 없습니다"
    
    log_success "Linux 환경 설정 완료"
}

# WSL 환경 설정
setup_wsl_env() {
    log_info "WSL 환경을 설정합니다..."
    
    # Windows IP 주소 찾기
    WINDOWS_IP=$(ip route show | grep -i default | awk '{ print $3}')
    
    # DISPLAY 환경변수 설정
    sed -i "s/DISPLAY=.*/DISPLAY=$WINDOWS_IP:0.0/" .env
    
    # 사용자 설정
    sed -i "s/USER_ID=.*/USER_ID=$(id -u)/" .env
    sed -i "s/GROUP_ID=.*/GROUP_ID=$(id -g)/" .env
    sed -i "s/USER_NAME=.*/USER_NAME=$USER/" .env
    
    log_warning "WSL에서는 Windows에 X11 서버(VcXsrv, X410 등)가 설치되어 있어야 합니다"
    log_info "Windows IP: $WINDOWS_IP"
    
    log_success "WSL 환경 설정 완료"
}

# macOS 환경 설정
setup_macos_env() {
    log_info "macOS 환경을 설정합니다..."
    
    # XQuartz 설정
    sed -i '' "s/DISPLAY=.*/DISPLAY=host.docker.internal:0/" .env
    
    log_warning "macOS에서는 XQuartz가 설치되어 있어야 합니다"
    log_info "XQuartz 설치: brew install --cask xquartz"
    
    log_success "macOS 환경 설정 완료"
}

# Windows 환경 설정
setup_windows_env() {
    log_info "Windows 환경을 설정합니다..."
    
    log_warning "Windows에서는 WSL2와 Docker Desktop이 필요합니다"
    log_warning "또한 X11 서버(VcXsrv, X410 등)가 설치되어 있어야 합니다"
    
    log_success "Windows 환경 설정 완료"
}

# Docker 이미지 빌드/풀
setup_docker_images() {
    log_info "Docker 이미지를 확인합니다..."
    
    # .env 파일에서 이미지 이름 읽기
    source .env
    
    if ! docker image inspect "$ROS2_IMAGE" >/dev/null 2>&1; then
        log_info "ROS2 이미지를 다운로드합니다: $ROS2_IMAGE"
        docker pull "$ROS2_IMAGE"
    else
        log_success "ROS2 이미지가 이미 존재합니다: $ROS2_IMAGE"
    fi
}

# 권한 설정
setup_permissions() {
    log_info "권한을 설정합니다..."
    
    # 스크립트 실행 권한
    chmod +x setup.sh
    chmod +x start.sh 2>/dev/null || true
    chmod +x stop.sh 2>/dev/null || true
    
    # 워크스페이스 권한
    sudo chown -R $USER:$USER workspace/ 2>/dev/null || {
        log_warning "sudo 권한이 없습니다. 수동으로 권한을 설정해주세요."
    }
    
    log_success "권한 설정 완료"
}

# 설정 파일 생성
create_config_files() {
    log_info "설정 파일을 생성합니다..."
    
    # ROS2 bashrc 설정
    cat > config/ros2_bashrc << 'EOF'
#!/bin/bash
# ROS2 환경 설정

# ROS2 소스
source /opt/ros/humble/setup.bash

# 워크스페이스 소스 (존재하는 경우)
if [ -f /workspace/install/setup.bash ]; then
    source /workspace/install/setup.bash
fi

# 유용한 별칭들
alias cb='colcon build'
alias cbs='colcon build --symlink-install'
alias cbp='colcon build --packages-select'
alias cbt='colcon test'
alias ctr='colcon test-result'

# ROS2 명령어 자동완성
eval "$(register-python-argcomplete3 ros2)"
eval "$(register-python-argcomplete3 colcon)"

# 프롬프트 설정
export PS1='\[\033[01;32m\][ROS2-$ROS_DISTRO]\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$ '

echo "ROS2 개발환경이 준비되었습니다!"
echo "ROS_DISTRO: $ROS_DISTRO"
echo "ROS_DOMAIN_ID: $ROS_DOMAIN_ID"
EOF
    
    log_success "설정 파일 생성 완료"
}

# 유틸리티 스크립트 생성
create_utility_scripts() {
    log_info "유틸리티 스크립트를 생성합니다..."
    
    # 시작 스크립트
    cat > start.sh << 'EOF'
#!/bin/bash
echo "ROS2 개발환경을 시작합니다..."
docker compose up -d
echo "컨테이너에 접속하려면: docker compose exec ros2-dev bash"
EOF
    
    # 중지 스크립트
    cat > stop.sh << 'EOF'
#!/bin/bash
echo "ROS2 개발환경을 중지합니다..."
docker compose down
EOF
    
    # 접속 스크립트
    cat > connect.sh << 'EOF'
#!/bin/bash
docker compose exec ros2-dev bash
EOF
    
    chmod +x start.sh stop.sh connect.sh
    
    log_success "유틸리티 스크립트 생성 완료"
}

# 메인 함수
main() {
    echo "========================================"
    echo "   ROS2 Docker 개발환경 자동 설정"
    echo "========================================"
    echo
    
    OS=$(detect_os)
    log_info "감지된 운영체제: $OS"
    echo
    
    create_directories
    setup_env_file
    setup_docker_images
    setup_permissions
    create_config_files
    create_utility_scripts
    
    echo
    echo "========================================"
    log_success "설정이 완료되었습니다!"
    echo "========================================"
    echo
    echo "다음 단계:"
    echo "1. .env 파일을 확인하고 필요에 따라 수정하세요"
    echo "2. 개발환경을 시작하세요: ./start.sh"
    echo "3. 컨테이너에 접속하세요: ./connect.sh"
    echo
    echo "유용한 명령어들:"
    echo "- 환경 시작: ./start.sh"
    echo "- 환경 중지: ./stop.sh"
    echo "- 컨테이너 접속: ./connect.sh"
    echo "- 로그 확인: docker compose logs -f"
    echo
}

# 스크립트 실행
main "$@"