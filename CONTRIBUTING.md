# Contributing

These rules apply across Great Falls Tool Bus. Each repository’s README names its development commands and gate.

## Before you start

Use Git 2.34 or later for SSH signing. Sign in to the GitHub CLI with `gh auth login` and register a signing key. Accept the organization invitation before forking a private repository.

For repositories with a flake, enable `experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`. [Install Nix](https://nixos.org/download/).

## Fork first

Clone your personal fork. Check that `origin` points to the fork and `upstream` to the organization.

    gh repo fork Great-Falls-Tool-Bus/<repo> --clone --remote
    cd <repo>
    git remote -v

If the repository has a flake, run `nix develop`. Where it tracks an `.envrc`, `direnv allow` enters the shell. Use its Just recipes inside that shell.

Sync your fork and branch from its current main:

    gh repo sync <your-login>/<repo> --source Great-Falls-Tool-Bus/<repo>
    git fetch origin
    git switch -c feat/short-slug origin/main

## Install the hooks

Where the repository supplies `.githooks/` and `just hooks-install`, run `just setup` once. It sets `core.hooksPath` to `.githooks`, makes `origin` the default push remote and disables pushes to a configured `upstream`. It warns if commit signing is off.

If the repository has no shared-hook setup, use a local checkout of the public organization `.github` repository. Preserve existing repository hooks. In a clone without a repository hook path, run:

    git config --local core.hooksPath /absolute/path/to/.github/githooks

The shared hooks chain to a different global `core.hooksPath`. Lab’s global hooks run Huskycat. In other contributor environments, put the pilot package on `PATH` and check `huskycat --version`. If a custom global hook handles commits without calling Huskycat, keep that hook and select the repository as formatter:

    git config --local gftb.huskycatOwner repo

Huskycat formats staged comments before signing and adds its commit-message receipt. The installed Lab release skips partially staged files. A partially staged comment that still needs formatting can leave a signed commit without a receipt. The pilot candidate formats the staged snapshot and preserves unstaged work.

The hooks refuse pushes to organization remotes, unsigned commits in the pushed range and AI attribution. GitHub merge commits have a signature exemption. The hooks warn about branch names, commit subjects and em dashes. On private GitHub Free repositories these local checks are advisory. Repository permissions control who can merge.

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

Describe the change and provide its gate receipt. Use a conventional subject for the title. Every repository lands PRs by squash, retaining the title and appending the PR number.

## Run the gate and paste the receipt

Run the gate named by the repository on a Linux host before requesting review. Run `just` to list the available recipes. Repositories use different gates, including `just check` and `just gate-deploy`. The platform’s release and changelog instructions belong to that repository.

Paste the tested commit SHA, host operating system, exact command and final output showing pass or fail. If you lack the required host or access, say so in the PR. A maintainer runs the gate and posts the receipt.

## Agents

Keep agent directives, skills, prompts and notes on your fork and out of upstream PRs. That includes `AGENTS.md`, `CLAUDE.md`, `.agents/` and `.claude/`. Use `.git/info/exclude` for untracked files in your clone. You sign and answer for changes you submit.

## How this text and the hooks are federated

Maintainers change `steering/CONTRIBUTING.md` and `steering/githooks/` in private meta first. Copy the exact bytes into the public `.github` repository as `CONTRIBUTING.md` and `githooks/`, then into each consumer’s `.githooks/`. GitHub displays the public guide for repositories without their own contributing guide. In meta, `just contributing-check` compares the canonical files with the public mirror.
