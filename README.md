# Vast PyTorch + Claude Code + Codex 사용설명서

Docker를 처음 사용하는 사람을 위한 안내입니다. **Vast에서 이 이미지를 사용하려면 내 PC에 Docker를 설치할 필요가 없습니다.** Vast가 이미지를 다운로드하고 실행합니다.

이미지는 만들어져 있습니다. 아래 주소를 Vast 템플릿의 **Image Path**에 넣으면 됩니다.

```text
ghcr.io/zxcyxv/vast-pytorch-cli:build-1
```

## 1. 먼저 알아둘 용어

| 용어 | 이 프로젝트에서의 의미 |
| --- | --- |
| 이미지(Image) | PyTorch와 두 CLI가 설치된, 새 환경을 만들기 위한 묶음 |
| 컨테이너(Container) | 이미지를 실행해서 만들어진 작업 환경 |
| 인스턴스(Instance) | Vast에서 빌린 GPU와 그 위의 작업 환경 |
| Dockerfile | 이미지에 무엇을 설치할지 적어 둔 제작 설명서 |
| 빌드(Build) | Dockerfile을 읽어 이미지를 만드는 과정 |
| 레지스트리(Registry) | 만들어진 이미지를 저장하고 내려받는 곳. 여기서는 GHCR 사용 |
| GHCR | GitHub Container Registry. `ghcr.io`로 시작하는 이미지 저장소 |
| 태그(Tag) | 이미지 주소의 `:build-1`, `:latest` 같은 버전 이름 |
| 템플릿(Template) | Vast에서 이미지, 접속 방식, 시작 옵션 등을 저장한 설정 |

전체 흐름은 다음과 같습니다.

```text
GitHub의 Dockerfile + 설치 스크립트
               ↓ GitHub Actions에서 빌드
GHCR에 완성 이미지 저장
               ↓ Vast가 다운로드
새 GPU 인스턴스에서 PyTorch · Claude · Codex 사용
```

GitHub 저장소에는 제작 파일과 이 설명서가 들어 있습니다. 완성 이미지는 GHCR에 별도로 저장됩니다.

## 2. 이 이미지에 들어 있는 것

- 공식 Vast PyTorch 이미지의 기본 환경과 서비스
- CUDA 12.8 계열 기반 환경
- Codex CLI `0.160.1`
- Claude Code `2.1.291`

PyTorch의 `/venv/main` 환경, 기본 시작 동작, SSH·Jupyter·portal 관련 구성은 기반 이미지에서 이어받습니다. 실제 접속 방식은 선택한 Vast 템플릿 설정에 따라 달라집니다.

Claude와 Codex는 터미널에서 쓰는 프로그램입니다. 모델 가중치를 GPU에 설치하는 구성이 아니므로, CLI 설치만으로 Claude나 OpenAI 모델을 로컬에서 실행하는 것은 아닙니다. 사용 시 해당 서비스 로그인과 인터넷 연결이 필요합니다.

로그인 정보, API 키, 개인 코드, 학습 데이터는 이미지에 포함되어 있지 않습니다.

## 3. 처음 한 번: Vast 템플릿 저장하기

아래 작업은 **내 PC의 웹 브라우저**에서 합니다.

1. [Vast 콘솔](https://console.vast.ai/)에 로그인합니다.
2. 템플릿 선택 화면에서 공식 **PyTorch** 템플릿을 찾습니다. 가능하면 지금 사용 중인 PyTorch 템플릿을 기준으로 합니다.
3. 해당 템플릿의 복제 또는 편집 기능으로 나만의 템플릿을 만듭니다. 버튼 이름은 콘솔 버전에 따라 달라질 수 있습니다.
4. Docker 이미지 설정의 **Image Path**를 다음 주소로 바꿉니다.

   ```text
   ghcr.io/zxcyxv/vast-pytorch-cli:build-1
   ```

5. 기존 PyTorch 템플릿의 시작 명령, 환경 변수, 포트 설정, SSH/Jupyter 접속 옵션은 유지합니다. 기본 템플릿에 별도의 Image Tag 칸이 있다면 이전 이미지의 태그가 남아 있지 않은지 확인합니다.
6. 이름을 `PyTorch + Claude + Codex`처럼 알아보기 쉽게 정하고 개인 템플릿으로 저장합니다.

Image Path에는 GitHub 저장소 URL이나 `.git` 주소를 넣지 않습니다. 위의 `ghcr.io/...` 주소를 사용합니다.

이 이미지는 생성 직후 인증 없이 레지스트리에서 접근 가능한 것을 확인했습니다. 공개 상태가 유지되는 동안 이미지 다운로드용 GitHub 로그인이나 토큰을 추가할 필요가 없습니다.

템플릿의 이미지 주소와 시작 옵션에 대한 기준은 [Vast 공식 Template Settings 문서](https://docs.vast.ai/guides/templates/template-settings)를 참고하세요.

## 4. 새 인스턴스 실행하기

아래 작업도 **Vast 웹 콘솔**에서 합니다.

1. 방금 저장한 `PyTorch + Claude + Codex` 템플릿을 선택합니다.
2. GPU 서버를 고르고, 이미지·코드·데이터를 담을 디스크 공간을 설정합니다. CUDA/PyTorch 이미지 자체가 크므로 데이터 공간까지 고려해야 합니다.
3. 새 인스턴스를 생성합니다.
4. 이미지 다운로드와 초기화가 끝날 때까지 기다립니다. 첫 실행은 캐시가 있는 서버보다 오래 걸릴 수 있습니다.
5. 인스턴스의 Jupyter/터미널 열기 기능을 사용하거나, Vast가 제공하는 SSH 접속 명령으로 접속합니다.

기존 인스턴스는 기존 이미지로 계속 동작합니다. **새 템플릿을 저장하는 것만으로 현재 인스턴스가 바뀌지는 않습니다.** 기존 작업을 옮길 계획이라면 먼저 필요한 파일을 백업하세요.

이후의 명령어는 별도 표시가 없는 한 **Vast 인스턴스 안의 터미널**에 입력합니다. 코드 블록 안의 명령만 복사하면 됩니다.

## 5. 설치와 GPU 확인하기

터미널에서 다음 명령을 실행합니다.

```bash
claude --version
codex --version
```

`build-1` 이미지에서는 다음 버전이 표시되어야 합니다.

```text
2.1.291 (Claude Code)
codex-cli 0.160.1
```

PyTorch와 GPU도 확인합니다.

```bash
/venv/main/bin/python -c 'import torch; print("PyTorch:", torch.__version__); print("CUDA:", torch.version.cuda); print("GPU available:", torch.cuda.is_available()); print(torch.ones(1, device="cuda"))'
```

`GPU available: True`와 CUDA 장치의 텐서가 나오면 GPU 연산이 된 것입니다. 오류가 나면 아래 문제 해결 항목을 확인하세요.

학습 작업을 할 때는 기본 Python 환경을 활성화합니다.

```bash
source /venv/main/bin/activate
python --version
```

## 6. Claude Code 로그인과 사용

프로젝트 폴더에서 Claude를 실행합니다. 처음에는 예제 폴더를 만들어도 됩니다.

```bash
mkdir -p /workspace/my-project
cd /workspace/my-project
claude
```

처음 실행 시 표시되는 로그인 안내를 따릅니다. 서버에서 브라우저가 자동으로 열리지 않으면 터미널에 표시된 URL을 **내 PC의 브라우저**에서 열고, 화면 안내에 따라 인증을 완료합니다.

로그인만 먼저 진행하려면 다음 명령을 사용할 수 있습니다.

```bash
claude auth login --claudeai
```

로그인 상태 확인:

```bash
claude auth status --text
```

로그인 후 `claude`를 실행하고, 예를 들어 다음처럼 요청합니다.

```text
현재 폴더에 PyTorch로 GPU 사용 여부를 확인하는 check_gpu.py를 만들어줘.
```

처음에는 파일 변경과 명령 실행 내용을 확인하면서 승인하세요. Claude 사용 권한과 사용량은 로그인한 계정의 조건을 따릅니다. API 사용량으로 로그인하려는 경우에는 구독 로그인과 구분하여 화면의 계정 옵션을 선택하세요.

명령 설명은 [Claude Code 공식 CLI 문서](https://code.claude.com/docs/en/cli-reference)에 있습니다.

## 7. Codex 로그인과 사용

Vast처럼 서버에서 접속하는 환경에서는 기기 코드 로그인을 사용할 수 있습니다.

```bash
codex login --device-auth
```

터미널에 나오는 URL을 **내 PC의 브라우저**에서 열고 표시된 코드를 입력합니다. 기기 코드 로그인이 비활성화되어 있다고 나오면 ChatGPT 계정의 보안 설정에서 허용 여부를 확인하세요. 조직 계정은 관리자가 제한할 수 있습니다.

로그인 상태 확인:

```bash
codex login status
```

프로젝트 폴더에서 실행:

```bash
cd /workspace/my-project
codex
```

예를 들어 다음처럼 요청할 수 있습니다.

```text
이 폴더의 PyTorch 코드를 읽고 실행 방법을 설명해줘.
```

계정 로그인 대신 API 키를 사용하면 API 사용에 대한 별도 과금 방식이 적용될 수 있습니다. 처음에는 사용하려는 계정의 로그인 방식을 확인하세요. 인증 방법은 [OpenAI 공식 Authentication 문서](https://learn.chatgpt.com/docs/auth)를 참고하세요.

## 8. 계속 쓰려면: 재시작과 데이터 보관

**이미지는 설치 환경을 재사용합니다. 작업 파일까지 자동으로 백업해 주지는 않습니다.**

| 행동 | 설치 환경과 파일에 미치는 영향 |
| --- | --- |
| 같은 인스턴스를 Stop 후 Start | 일반적으로 기존 컨테이너 파일이 유지되어 이어서 작업 가능 |
| 같은 이미지로 새 인스턴스 생성 | 프로그램이 설치된 새 환경. 개인 파일과 로그인은 별도로 준비 |
| 인스턴스 Recycle 또는 Destroy | 컨테이너 파일이 사라질 수 있음. 볼륨과 외부 백업 여부 확인 |
| GitHub의 Dockerfile 수정 | 현재 실행 중인 인스턴스는 변경되지 않음 |

인스턴스에서 `/workspace`가 영구 볼륨인지 확인합니다.

```bash
vast-capabilities | jq '.instance.workspace_is_volume'
```

- `true`: `/workspace`가 호스트 볼륨입니다. 삭제·분리할 볼륨의 보존 조건도 확인하세요.
- `false`: `/workspace`도 컨테이너 내부 저장소입니다. 재생성·삭제 전에 필요한 파일을 외부로 옮겨야 합니다.

이 이미지를 처음 준비한 인스턴스에서는 `false`였습니다. 새 인스턴스는 별도로 확인해야 합니다.

코드는 Git으로 보관하고, 데이터와 모델 체크포인트는 PC 다운로드나 별도 저장소 동기화 등으로 백업하세요. 로그인 파일과 API 키는 공개 GitHub 저장소에 올리지 마세요.

GPU를 잠시 쓰지 않을 때 Stop을 사용할 수 있습니다. Stop 이후에도 저장 공간 요금은 남을 수 있으므로 Vast의 표시를 확인하세요. Destroy는 필요한 파일을 백업한 뒤 사용합니다.

## 9. 이미지 주소를 고르는 방법

| 주소 | 언제 사용하는가 |
| --- | --- |
| `ghcr.io/zxcyxv/vast-pytorch-cli:build-1` | 이번 첫 빌드 버전을 선택할 때 |
| `ghcr.io/zxcyxv/vast-pytorch-cli:latest` | 앞으로 성공한 가장 최근 빌드로 새 인스턴스를 만들 때 |
| `ghcr.io/zxcyxv/vast-pytorch-cli@sha256:...` | 정확히 같은 이미지 내용으로 고정하고 싶을 때 |

태그는 이름이므로 재업로드하면 내용이 달라질 수 있습니다. 내용까지 고정하려면 아래 전체 주소를 사용합니다.

```text
ghcr.io/zxcyxv/vast-pytorch-cli@sha256:7518a54cfd13cef26b43692f5c499149d77f5c682d85afc9c6fbd224ad93f16e
```

이 주소를 Vast의 Image Path로 사용할 수 있습니다. 이후에는 성공한 Actions 실행의 요약 화면에서 새 digest 주소를 확인하세요.

## 10. 프로그램 버전 업데이트하기

처음 사용할 때는 이 항목을 건너뛰어도 됩니다. **새 버전 이미지를 만드는 작업**입니다.

1. GitHub에서 [Dockerfile](Dockerfile)을 엽니다.
2. 편집 버튼을 누르고 다음 두 항목 중 업데이트할 프로그램의 버전을 바꿉니다. 해당 배포처에 실제로 존재하는 버전을 지정해야 합니다.

   ```dockerfile
   ARG CODEX_VERSION=0.160.1
   ARG CLAUDE_VERSION=2.1.291
   ```

3. 변경 내용을 `main` 브랜치에 커밋합니다.
4. [Actions](https://github.com/zxcyxv/vast-pytorch-cli/actions)에서 자동으로 시작된 빌드를 확인합니다.
5. 초록색 성공 표시가 나면 이미지가 GHCR에 업로드된 것입니다. `latest`와 `build-실행번호` 태그가 생성됩니다.
6. 사용할 Vast 템플릿의 Image Path를 새 빌드 태그 또는 digest로 바꾸고, 필요할 때 새 인스턴스를 만듭니다.

빌드 실패 시 새 이미지는 사용할 준비가 되지 않은 것입니다. 빨간색 실행을 열어 실패한 단계의 로그를 확인하세요. 이전에 성공한 이미지 주소는 계속 사용할 수 있습니다.

수동 빌드는 Actions에서 `Build and publish Vast PyTorch CLI image`를 선택하고 **Run workflow**를 눌러 실행합니다. 버전을 수정하지 않고 실행하면 같은 버전으로 다시 빌드합니다.

Claude의 자동 업데이트는 이 이미지에서 꺼 두었습니다. 이미지 버전을 관리하려면 Dockerfile 수정 후 재빌드하는 방식을 사용합니다. 기반 PyTorch 이미지는 digest로 고정되어 있으므로 CLI 버전 변경만으로 PyTorch가 자동 업데이트되지는 않습니다.

문서만 수정할 때는 빌드를 실행하지 않도록 워크플로가 설정되어 있습니다.

## 11. 자주 생기는 문제

### `claude: command not found` 또는 `codex: command not found`

먼저 새 인스턴스를 이 이미지로 생성했는지 확인합니다. 기존 PyTorch 인스턴스에서 템플릿 주소만 바꾸면 설치되지 않습니다.

아래 절대 경로로도 확인합니다.

```bash
/opt/ai-cli/bin/claude --version
/opt/ai-cli/bin/codex --version
```

절대 경로는 실행되는데 짧은 명령만 안 된다면 현재 셸에서 경로를 추가합니다.

```bash
export PATH="/opt/ai-cli/bin:$PATH"
```

### 이미지 다운로드가 거절됨

Image Path의 철자와 `ghcr.io/` 부분을 확인합니다. GitHub 저장소의 공개 설정과 컨테이너 패키지의 공개 설정은 별개입니다. 패키지 공개 범위가 바뀌었다면 GHCR 패키지 설정을 확인하세요.

### GPU 확인에서 `False` 또는 CUDA 오류가 나옴

```bash
nvidia-smi
/venv/main/bin/python -c 'import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())'
vast-capabilities | jq '.hardware.gpu.cuda'
```

출력과 전체 오류 메시지로 GPU 연결, 드라이버, PyTorch 빌드 호환성을 확인합니다. 문제 해결을 위해 컨테이너 안에서 NVIDIA 드라이버를 교체하지 마세요. 드라이버는 호스트에서 제공됩니다.

### 로그인 링크가 서버에서 열리지 않음

링크를 PC 브라우저에 복사해서 엽니다. Codex는 앞서 안내한 `codex login --device-auth`를 사용합니다. Claude는 `claude auth login --claudeai` 후 표시되는 안내를 따릅니다.

### 새 인스턴스에서 코드나 로그인 상태가 사라짐

새 컨테이너에는 이미지에 넣은 프로그램만 준비됩니다. 이전 인스턴스의 작업 파일을 가져오고 다시 로그인합니다. 자동 데이터 보관이 필요하면 별도의 볼륨 또는 백업 구성을 마련해야 합니다.

## 12. 저장소 파일 안내와 확인된 범위

| 파일 | 역할 |
| --- | --- |
| [README.md](README.md) | 이 사용설명서 |
| [Dockerfile](Dockerfile) | 기반 이미지와 설치할 CLI 버전 |
| [install-cli.sh](install-cli.sh) | Codex 설치, Claude 다운로드·체크섬 확인, 버전 확인 |
| [.github/workflows/build-image.yml](.github/workflows/build-image.yml) | GitHub 서버에서 자동 빌드하고 GHCR에 업로드 |
| [.dockerignore](.dockerignore) | 빌드에 필요한 파일만 포함하도록 제한 |
| [VALIDATION.txt](VALIDATION.txt) | 이미지 준비 당시의 인스턴스 검증 기록 |
| [BUILD_RESULT.txt](BUILD_RESULT.txt) | 첫 이미지의 빌드 결과와 고정 주소 |

첫 이미지의 [GitHub Actions 빌드](https://github.com/zxcyxv/vast-pytorch-cli/actions/runs/37444724817)는 성공했습니다. 빌드 중 두 CLI의 버전 확인도 통과했고, 업로드 직후 인증 없는 이미지 manifest 접근을 확인했습니다.

준비에 사용한 기존 RTX 3090 인스턴스에서는 PyTorch GPU 연산을 확인했습니다. **완성 이미지를 사용한 새 Vast 인스턴스의 기동과 GPU 연산은 아직 별도로 검증하지 않았습니다.** 새 인스턴스를 생성하면 5번 항목을 실행해서 확인하세요.

## 13. 내 PC에서도 Docker를 쓰고 싶다면 (선택)

Vast 사용에는 필요 없는 단계입니다. 직접 빌드할 때만 Docker를 지원하는 PC 또는 VM을 사용합니다. 일반 Vast GPU 컨테이너 내부에 Docker 엔진을 추가해서 빌드하는 방식은 이 환경에서 지원되지 않습니다.

Docker가 설치된 PC에서 소스만 내려받으려면 다음처럼 합니다.

```bash
git clone https://github.com/zxcyxv/vast-pytorch-cli.git
cd vast-pytorch-cli
```

로컬 이미지 제작:

```bash
docker build --platform linux/amd64 -t vast-pytorch-cli:local .
```

`-t`는 결과에 붙일 이름입니다. 로컬 빌드만으로 GHCR에 업로드되지는 않습니다. 서버에서 재사용할 목적이면 이 저장소의 GitHub Actions를 사용하는 편이 절차가 적습니다.

이미 만들어진 이미지의 CLI만 PC에서 확인하려면 다음 명령을 사용할 수 있습니다. 이미지 다운로드에 많은 저장 공간이 필요하며, 아래 확인에는 GPU가 필요하지 않습니다.

```bash
docker run --rm --platform linux/amd64 --entrypoint /bin/bash ghcr.io/zxcyxv/vast-pytorch-cli:build-1 -lc 'claude --version && codex --version'
```

`--rm`은 이 확인용 컨테이너가 종료되면 삭제한다는 뜻입니다. `--entrypoint`는 기본 Vast 시작 절차 대신 버전 확인 명령을 실행하기 위한 옵션입니다. 로컬 GPU 학습을 위한 Docker 설정은 이 설명서의 범위에 포함하지 않습니다.
