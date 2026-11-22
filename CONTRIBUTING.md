# Contributing

These rules apply across Great Falls Tool Bus. Consult the repository’s contributor guide and, where available, its Justfile for development commands and the gate.

## Before you start

Use Git 2.34 or later for SSH signing. Sign in to the GitHub CLI with `gh auth login` and register a signing key. Accept the organization invitation before forking a private repository.

For repositories with a flake, enable `experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`. [Install Nix](https://nixos.org/download/).

## Fork first

Clone your personal fork, named `<repo>-contrib`. Check that `origin` points to the fork and `upstream` to the organization.

    gh repo fork Great-Falls-Tool-Bus/<repo> --fork-name <repo>-contrib --clone --remote
    cd <repo>-contrib
    git remote -v

If your fork still has the plain name, rename it and point `origin` at the new name:

    gh repo rename <repo>-contrib -R <your-login>/<repo>
    git remote set-url origin https://github.com/<your-login>/<repo>-contrib.git

For an SSH remote, set `origin` to the SSH form instead:

    git remote set-url origin git@github.com:<your-login>/<repo>-contrib.git

If the repository has a flake, run `nix develop`. Where it tracks an `.envrc`, `direnv allow` enters the shell. Use its Just recipes inside that shell.

Sync your fork and branch from its current main:

    gh repo sync <your-login>/<repo>-contrib --source Great-Falls-Tool-Bus/<repo>
    git fetch origin
    git switch -c feat/short-slug origin/main

## Install the hooks

Where the repository supplies `.githooks/` and `just hooks-install`, run `just setup` once. It sets `core.hooksPath` to `.githooks`, makes `origin` the default push remote and disables pushes to a configured `upstream`. It warns if commit signing is off.

If the repository has no shared-hook setup, use a local checkout of the public organization `.github` repository. Preserve existing repository hooks. In a clone without a repository hook path, run:

    git config --local core.hooksPath /absolute/path/to/.github/githooks

The shared hooks chain to a different global `core.hooksPath`. Lab’s global hooks run Huskycat. In other contributor environments, put the pilot package on `PATH` and check `huskycat --version`. If a custom global hook handles commits without calling Huskycat, keep that hook and select the repository as formatter:

    git config --local gftb.huskycatOwner repo

Huskycat formats staged comments before signing and adds its commit-message receipt. The installed Lab release skips partially staged files. A partially staged comment that still needs formatting can leave a signed commit without a receipt. The pilot candidate formats the staged snapshot and preserves unstaged work.

The hooks refuse pushes to organization remotes, unsigned commits in the pushed range and AI attribution. GitHub merge commits have a signature exemption. The hooks warn about branch names, commit subjects and em dashes. They also warn when a push to the organization adds a path from `tooling-paths.txt` in the shared hooks. On private GitHub Free repositories these local checks are advisory. Repository permissions control who can merge.

Where supplied, `just hooks-check` compares the installed hooks with the public mirror. `just hooks-test` runs the fixtures.

## Branches

Use a short kebab-case slug after `feat/`, `fix/`, `hotfix/`, `docs/`, `chore/` or `ci/`. For example, `feat/member-signup-copy`.

## Commits

Use a Conventional Commits subject, `type(scope): summary`. The scope is optional. The branch prefixes also work as commit types. Additional types are `build`, `perf`, `refactor`, `revert`, `style` and `test`.

Sign every commit as yourself with a key registered on GitHub. Verify that GitHub shows it as verified. Human `Co-Authored-By` trailers are allowed. Omit AI or vendor attribution, “Generated with” lines, robot emoji and `[codex]` prefixes from commits, PR titles, descriptions and comments. Avoid em dashes in new text. Existing ones can stay until the paragraph is rewritten.

## Set up commit signing

For SSH, generate a key if needed. Register its public key under GitHub Settings, SSH and GPG keys. Select *Signing key* for commits. For SSH cloning, register it separately as an *Authentication key*, even if you use the same file.

    ssh-keygen -t ed25519 -C "your-github-login"

Configure signing and local verification with your public key:

    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/id_ed25519.pub
    git config --global commit.gpgsign true
    mkdir -p ~/.config/git
    echo "$(git config user.email) $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
    git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

For GPG, register your public GPG key on GitHub, set `gpg.format` to `openpgp`, set `user.signingkey` to its fingerprint and enable `commit.gpgsign`. GitHub’s vigilant mode flags unsigned commits in your name.

Test signing in a disposable repository:

    cd "$(mktemp -d)" && git init -q && git commit -q --allow-empty -m "chore: signing check"
    git log -1 --format='%G?'

Expect `G`. For an unsigned or unverified commit, check your signing configuration and, for SSH, your allowed-signers file.

## Pull requests and landing

Push your branch to your fork and open a PR into upstream `main`:

    git push -u origin <branch>
    gh pr create --repo Great-Falls-Tool-Bus/<repo> --head <your-login>:<branch>

Describe the change. Use a conventional subject for the title. Every repository lands PRs by squash, retaining the title and appending the PR number.

## Run the checks

Run the repository's checks on a Linux host before requesting review. Run `just` to list the recipes. Repositories use different gates, including `just check` and `just gate-deploy`. The platform’s release and changelog instructions belong to that repository. If you lack the required host or access, say so in the PR and a maintainer runs them.

## Agents

Agent tooling stays on your `<repo>-contrib` fork, on its `agents-overlay` branch. It never lands on upstream or in an upstream PR. It covers two kinds of files:

- Directives, skills, prompts, plugins and notes, such as `AGENTS.md`, `CLAUDE.md`, `.agents/` and `.claude/`.
- Scripts and receipts that exist to drive agent sessions, such as release sitting packets, gate scripts and merge receipt scripts.

`tooling-paths.txt` in the shared hooks lists the enforced paths. Hooks, CI and the product's own features stay out of it. Each exception names one exact path, a ticket and a reason. In meta, `just upstream-tooling-audit` checks every default branch against the list on meta's default branch, and `just upstream-tooling-audit pr <repo> <number>` checks one PR before merge. Use `.git/info/exclude` for untracked files in your clone. You sign and answer for changes you submit.

## How this text and the hooks are federated

Maintainers change `steering/CONTRIBUTING.md` and `steering/githooks/` in private meta first. Copy the exact bytes into the public `.github` repository as `CONTRIBUTING.md` and `githooks/`, then into each consumer’s `.githooks/`. GitHub displays the public guide for repositories without their own contributing guide. In meta, `just contributing-check` compares the canonical files with the public mirror.
