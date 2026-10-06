Vast PyTorch + Claude Code + Codex CLI

구성
- Vast 공식 PyTorch CUDA 12.8.1 이미지 (digest 고정)
- Codex CLI 0.160.1 / Claude Code 2.1.291 (버전 고정)
- Vast의 PyTorch, Jupyter, SSH, portal 및 기존 시작 동작 유지
- 로그인 정보, API 키, 작업 파일은 포함하지 않음
- CLI는 /opt/ai-cli/bin에 설치. 비대화형 셸에서도 실행 가능
- Claude 자동 업데이트 비활성화. 업데이트는 버전을 수정하고 재빌드

GitHub Actions로 빌드 (현재 Vast 컨테이너에는 Docker 엔진 없음)
1. GitHub에 새 저장소를 만들고 이 폴더의 파일을 업로드한다.
   숨김 폴더 .github/workflows 및 .dockerignore도 반드시 포함한다.
2. Actions > Build and publish Vast PyTorch CLI image > Run workflow 실행.
3. 성공하면 ghcr.io/계정/저장소:latest 이미지가 생성된다 (소문자).
   Actions 요약에는 재사용 가능한 digest 고정 주소도 기록된다.
4. GitHub Packages에서 이미지의 공개 범위를 Public으로 설정하면
   Vast에서 별도 registry 로그인 없이 가져올 수 있다.
   Private으로 유지하면 Vast에 별도의 registry 인증을 설정한다.
5. Vast의 기본 PyTorch 템플릿을 복제하여 Image Path만 위 주소로 바꾸고
   새 이름으로 저장한다. 기존 시작 설정, 포트와 Docker 옵션은 유지한다.
6. 새 인스턴스에서 claude 및 codex 실행 후 각 계정에 로그인한다.

Docker 사용 가능한 로컬 PC 또는 VM에서도 빌드 가능
  docker build --platform linux/amd64 -t 계정/vast-pytorch-cli:1 .
  docker login
  docker push 계정/vast-pytorch-cli:1
Vast Image Path: 계정/vast-pytorch-cli:1

GPU 확인 (새 인스턴스에서)
  /venv/main/bin/python -c 'import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available()); print(torch.ones(1, device="cuda"))'
  claude --version
  codex --version

현재 인스턴스에서의 검증은 VALIDATION.txt 참조.
main 브랜치에 빌드 파일을 올리면 GitHub Actions가 자동으로 빌드한다.
실제 Docker 빌드 결과는 GitHub Actions에서 확인한다. Vast 새 인스턴스 기동은 미검증.
현재 /workspace는 영구 볼륨이 아니므로 폴더/압축파일을 다운로드해 보관한다.
이미지는 설치 환경을 재사용한다. 새 인스턴스의 작업 파일과 로그인 상태까지
자동으로 보존하지는 않는다.

공식 참고 문서
https://github.com/vast-ai/base-image/tree/main/derivatives/pytorch
https://learn.chatgpt.com/docs/codex/cli
https://code.claude.com/docs/en/setup
