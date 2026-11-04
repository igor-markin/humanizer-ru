#!/usr/bin/env bash
# Один раз ставит зависимости сканера в отдельный venv.
# Системный Python не трогается; версии и хеши берутся из requirements.lock.
# Путь venv: $HUMANIZER_RU_VENV или ~/.venvs/humanizer-ru.
# После установки scan.py сам находит этот venv, команда в SKILL.md та же.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
venv="${HUMANIZER_RU_VENV:-$HOME/.venvs/humanizer-ru}"
py="${PYTHON:-python3}"

"$py" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' || {
  printf 'Нужен Python 3.10 или новее, а %s старше. Задайте другой через PYTHON=...\n' "$py" >&2
  exit 1
}

"$py" -m venv "$venv"
"$venv/bin/python" -m pip install -r "$here/requirements.lock" \
  --require-hashes --only-binary=:all: --quiet --disable-pip-version-check
"$venv/bin/python" "$here/scan.py" - <<'TXT' >/dev/null || [ $? -eq 1 ]
Проверка установки сканера.
TXT
printf 'Готово: %s\n' "$venv"
