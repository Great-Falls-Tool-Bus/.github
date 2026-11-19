default:
    @just --list

setup: hooks-install

hooks-install:
    #!/usr/bin/env bash
    set -euo pipefail
    git config --local core.hooksPath .githooks
    git config --local remote.pushDefault origin
    if git remote get-url upstream >/dev/null 2>&1; then
        git remote set-url --push upstream DISABLED-fork-first
    fi
    if [[ "$(git config --get commit.gpgsign || true)" != true ]]; then
        echo 'Configure commit signing before pushing. See CONTRIBUTING.md.' >&2
    fi

# Compare with the public mirror or a reviewed copy of the executable hooks from meta/.githooks.
[positional-arguments]
hooks-check source='':
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "$(readlink .githooks)" != githooks ]]; then
        echo 'hooks-check: .githooks must point to githooks' >&2
        exit 1
    fi
    source="$1"
    if [[ -z "$source" ]]; then
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        git clone --quiet --depth 1 --filter=blob:none --no-checkout --branch main https://github.com/Great-Falls-Tool-Bus/.github.git "$tmp/mirror"
        git -C "$tmp/mirror" checkout --quiet HEAD -- githooks
        source="$tmp/mirror/githooks"
    fi
    git -c core.filemode=true diff --no-index --exit-code -- "$source" githooks

hooks-test:
    bash .githooks/test.sh

check: hooks-check hooks-test
