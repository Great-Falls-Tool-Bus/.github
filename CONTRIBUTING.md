# Contributing

This is the contribution contract for every Great Falls Tool Bus repository.
The canonical copy lives at `steering/CONTRIBUTING.md` in the private `meta`
repository; see "How this text and the hooks are federated" at the end for
how the same bytes reach every other repository.

## Before you start

You need four things on your machine before the first clone:

- `git`, version 2.34 or later (SSH commit signing needs it).
- [Nix](https://nixos.org/download/) with flakes enabled
  (`experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`).
  Every repository's devshell provides `just` and the rest of its tools, so
  you do not install them yourself.
- The GitHub CLI `gh`, signed in once with `gh auth login`.
- A signing key registered on your GitHub account and configured in git
  (section "Set up commit signing" below).

Most repositories are private. To fork one you must first accept an
invitation to the organization; ask the owner for one.

## Fork first

Work from a personal fork. Your fork is `origin`; the Great Falls Tool Bus
repository is `upstream`. Pushes go to your fork, never to upstream.

    gh repo fork Great-Falls-Tool-Bus/<repo> --clone --remote
    cd <repo>
    git remote -v                      # origin = your fork, upstream = Great-Falls-Tool-Bus
    nix develop                        # enter the devshell; it provides just
    just setup                         # installs the hooks, see the next section

Run `just` from inside the devshell. Where the repository tracks an `.envrc`,
`direnv allow` enters the devshell for you.

Keep your fork's `main` level with upstream before you branch:

    gh repo sync <your-login>/<repo> --source Great-Falls-Tool-Bus/<repo>
    git fetch origin
    git switch -c feat/short-slug origin/main

Every change lands as a pull request from a branch on your fork into upstream
`main`. The pre-push hook refuses any push to a `Great-Falls-Tool-Bus`
remote.

## Install the hooks

Every repository carries the same git hooks in `.githooks/`. Install them
once per clone:

    just setup                         # runs just hooks-install

`just hooks-install` points `core.hooksPath` at `.githooks`, sets
`remote.pushDefault` to `origin`, disables pushes to an `upstream` remote,
and warns when `commit.gpgsign` is not set. If you already use a global
`core.hooksPath`, the repository hooks run first and then hand over to yours.

The hooks refuse three things:

- a push to any `Great-Falls-Tool-Bus` remote;
- an unsigned commit in the range you push (merge commits made by GitHub are
  exempt);
- AI attribution in a commit message: a `Co-Authored-By` trailer naming an
  AI or an AI vendor address, a "Generated with" line, a robot emoji, or a
  `[codex]` subject prefix. `Co-Authored-By` trailers for people are fine.

They warn, without refusing, about a branch name without a semantic prefix,
a subject that is not a conventional commit, and em dashes. Every message
names the section of this file that explains the rule and the exact command
that fixes it. On GitHub Free nothing on the server enforces these rules, so
the hooks are advisory; the repository role model is the merge control, and a
reviewer will send back a pull request that breaks them.

`just hooks-check` compares the repository's `.githooks/` with the
organization copy, and `just hooks-test` runs the hooks against throwaway
fixture commits.

## Branches

Branch names are semantic: a type prefix, a slash, and a short kebab-case
slug.

| Prefix | Use |
|---|---|
| `feat/` | new behaviour or content |
| `fix/` | a defect correction |
| `hotfix/` | an urgent correction landing ahead of the queue |
| `docs/` | documentation only |
| `chore/` | maintenance with no behaviour change |
| `ci/` | gate, runner, or check changes |

Examples: `feat/member-signup-copy`, `fix/release-subject-regex`,
`ci/hooks-self-test`.

## Commits

- Commit subjects follow Conventional Commits: `type(scope): summary`, with
  the scope optional. Use the branch prefixes above as types; `build`,
  `perf`, `refactor`, `revert`, `style` and `test` are also accepted.
- Every commit is signed with a key registered on your GitHub account, and
  GitHub must show it as verified. Section "Set up commit signing" below
  covers the key setup.
- Commit as yourself. Do not add AI attribution anywhere: no
  `Co-Authored-By` trailers for an AI, no tool prefixes in pull request
  titles, no generated-by lines in commits, pull request bodies or comments.
- Do not use em dashes in text you author. Files that already contain them
  may keep them until the paragraph is rewritten.

## Set up commit signing

On GitHub an SSH key is uploaded twice, even when it is the same file: once
as an *Authentication key* (for cloning over SSH) and once as a *Signing key*
(for verified commits). Generate a key if you do not have one, then upload
`~/.ssh/id_ed25519.pub` under Settings, SSH and GPG keys, both ways:

    ssh-keygen -t ed25519 -C "your-github-login"

Configure git to sign every commit, and give it an allowed-signers file so it
can verify your own signatures locally:

    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/id_ed25519.pub
    git config --global commit.gpgsign true
    mkdir -p ~/.config/git
    echo "$(git config user.email) $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
    git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

Check it in a throwaway repository, so no test commit lands in a real clone:

    cd "$(mktemp -d)" && git init -q && git commit -q --allow-empty -m "chore: signing check"
    git log -1 --format='%G?'          # must print G

`N` means the commit is unsigned or git cannot verify it; recheck the
allowed-signers line. GPG is an accepted alternative: upload the public key
under GPG keys and set `gpg.format` to `openpgp`. Turning on vigilant mode
("Flag unsigned commits as unverified" on the same settings page) makes an
unsigned commit in your name visibly unverified.

## Pull requests and landing

- Open the pull request from your fork branch into upstream `main`:

      gh pr create --repo Great-Falls-Tool-Bus/<repo> --head <your-login>:<branch>

- The title is a conventional commit subject; it becomes the landed commit
  subject.
- Say what the change does and paste the gate receipt (next section). A
  claim such as "verified" or "green" needs a receipt in the description.
- Pull requests land by squash in every repository. The squash commit keeps
  the pull request title and appends the pull request number.

## Run the gate and paste the receipt

No GitHub Actions workflow gates a pull request in any Great Falls Tool Bus
repository. The gate is the repository's own `just` recipe, run on a Linux
host before you ask for review:

    just check          # or the recipe the repository's README names as its gate

If the repository has no `check` recipe, `just` lists what it does have. The
receipt you paste into the pull request is the commit SHA you ran against,
the host's operating system, the exact command, and the last lines of its
output, including the pass or fail line. Some gates need keys or a lab host
you do not hold; say so in the pull request and a maintainer will run the
gate and post the receipt.

`greatfallstoolbus.org` is the one repository where workflows still run on a
pull request, and none of them is a required check. Its `changelog-gate`
fails when `## [Unreleased]` in `CHANGELOG.md` is empty outside a release
pull request (that repository's `RELEASING.md` explains releases), and two
path-scoped checks run only when you change their own files. On a fork pull
request these runs can wait for a maintainer to approve them; a waiting run
is not a failure of your change.

## Agents

Bring your own agent tooling and keep it on your fork. Upstream repositories
carry no agent directives: no `AGENTS.md`, `CLAUDE.md`, `.agents/`,
`.claude/`, skills, prompts, or agent notes, and a pull request that adds one
is sent back. Keep such files untracked, for example by listing them in
`.git/info/exclude` in your clone.

The hooks hold an agent to the same rules as a person: it pushes to your fork,
signs your commits with your key, and adds no AI attribution. You are the
author of what your agent writes and you answer for it in review.

## How this text and the hooks are federated

The organization `.github` repository carries a byte-identical copy of this
file at its root, and a byte-identical copy of the hooks in `githooks/`.
GitHub serves this file as the contributing guide for every repository in the
organization that has no `CONTRIBUTING.md` of its own, so one file covers
every repository. Each repository vendors the hooks in `.githooks/`.

`meta` is the source: this file is `steering/CONTRIBUTING.md` and the hooks
are `steering/githooks/`. `just contributing-check` in `meta` fetches the
organization copies and fails on any byte difference, and `just hooks-check`
in every repository does the same for its `.githooks/`. Change `meta` first,
then mirror the exact bytes to the `.github` repository, then to each
repository's `.githooks/`.
