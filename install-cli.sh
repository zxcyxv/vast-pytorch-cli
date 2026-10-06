#!/usr/bin/env bash
set -euo pipefail
CODEX_VERSION="${CODEX_VERSION:-0.160.1}"
CLAUDE_VERSION="${CLAUDE_VERSION:-2.1.291}"
CLI_PREFIX="${CLI_PREFIX:-/opt/ai-cli}"
[[ "$CODEX_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ "$CLAUDE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
if ! command -v npm >/dev/null 2>&1; then
    # nvm is installed by Vast but unavailable in noninteractive shells.
    set +u
    . /opt/nvm/nvm.sh
    set -u
fi
mkdir -p "$CLI_PREFIX/bin"
cli_tmp=$(mktemp -d)
trap 'rm -rf "$cli_tmp"' EXIT
npm_config_cache="$cli_tmp/npm-cache" npm install --global --prefix "$CLI_PREFIX" \
    "@openai/codex@$CODEX_VERSION" --no-audit --no-fund
# An explicit Node path makes Codex work over SSH and in supervisor too.
ln -sfn "$(command -v node)" "$CLI_PREFIX/bin/node"
rm "$CLI_PREFIX/bin/codex"
printf '#!/usr/bin/env bash\nexec %q %q "$@"\n' \
    "$CLI_PREFIX/bin/node" "$CLI_PREFIX/lib/node_modules/@openai/codex/bin/codex.js" \
    > "$CLI_PREFIX/bin/codex"
chmod 755 "$CLI_PREFIX/bin/codex"
case "$(uname -m)" in
    x86_64) claude_platform=linux-x64 ;;
    aarch64) claude_platform=linux-arm64 ;;
    *) echo 'Unsupported CPU architecture' >&2; exit 1 ;;
esac
# Download the pinned native release from Anthropic and verify its manifest checksum.
claude_url="https://downloads.claude.ai/claude-code-releases/$CLAUDE_VERSION"
curl --fail --silent --show-error --location --retry 3 \
    "$claude_url/manifest.json" -o "$cli_tmp/manifest.json"
claude_sha=$(jq -er --arg platform "$claude_platform" '.platforms[$platform].checksum' "$cli_tmp/manifest.json")
[[ "$claude_sha" =~ ^[a-f0-9]{64}$ ]]
curl --fail --silent --show-error --location --retry 3 \
    "$claude_url/$claude_platform/claude" -o "$cli_tmp/claude"
printf '%s  %s\n' "$claude_sha" "$cli_tmp/claude" | sha256sum --check -
install -m 755 "$cli_tmp/claude" "$CLI_PREFIX/bin/claude"
"$CLI_PREFIX/bin/codex" --version
DISABLE_AUTOUPDATER=1 "$CLI_PREFIX/bin/claude" --version
printf 'codex=%s\nclaude=%s\n' "$CODEX_VERSION" "$CLAUDE_VERSION" > "$CLI_PREFIX/versions.txt"
