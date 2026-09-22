# Contributing

This is the contribution contract for every Great Falls Tool Bus repository.
The canonical copy lives at `steering/CONTRIBUTING.md` in the private `meta`
repository; see "How this text is federated" at the end for how the same
bytes reach every other repository.

## Fork first

Work from a personal fork. Your fork is `origin`; the Great Falls Tool Bus
repository is `upstream`. Pushes go to your fork by default.

    gh repo fork Great-Falls-Tool-Bus/<repo> --clone --remote
    cd <repo>
    git remote -v                      # origin = your fork, upstream = Great-Falls-Tool-Bus
    git config remote.pushDefault origin

Keep your fork's `main` level with upstream before you branch:

    gh repo sync <your-login>/<repo> --source Great-Falls-Tool-Bus/<repo>
    git fetch origin
    git switch -c feat/short-slug origin/main

Never push directly to upstream `main`. Every change lands as a pull request
into upstream `main`.

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
| `ci/` | workflow, runner, or check changes |

Examples: `feat/member-signup-copy`, `fix/release-subject-regex`,
`ci/fork-pr-admission`.

## Commits

- Commit subjects follow Conventional Commits: `type(scope): summary`, with
  the scope optional. Types match the branch prefixes above.
- Every commit is signed with a key registered on your GitHub account, and
  GitHub must show it as verified. The private onboarding guide covers key
  setup.
- Commit as yourself. Do not add AI attribution anywhere: no
  `Co-Authored-By` trailers for an AI, no tool prefixes in pull request
  titles, no generated-by lines in pull request bodies or comments.
- Do not use em dashes in text you author. Files that already contain them
  may keep them until the paragraph is rewritten.

## Pull requests and landing

- Open the pull request from your fork branch into upstream `main`.
- The title is a conventional commit subject; it becomes the landed commit
  subject.
- Say what the change does and what you ran. A claim such as "verified" or
  "green" needs a receipt in the description.
- Landing method is squash everywhere, once the release-subject regex change
  in `greatfallstoolbus.org` has landed. Until then `greatfallstoolbus.org`
  lands by rebase, because its `release.yml` matches the release subject
  pattern against the landed commit subject and a squash commit carries a
  trailing pull request number that the current pattern rejects. Decision
  0028 section 6 records the per-repository methods and this follow-up:
  <https://github.com/Great-Falls-Tool-Bus/meta/blob/main/decisions/0028-contributor-access-and-repo-hygiene-2026-09-09.md#6-landing-methods-as-practised>

## CI on fork pull requests

The organization is on GitHub Free with no branch protection or rulesets. CI
results are a signal for the reviewer, not a merge gate; the repository role
model is the merge control.

Until the ci-templates admission change lands, a pull request from a fork
into a private repository runs no workflows at all. So before opening a pull
request, run the repository's own gate locally and record the result in the
description:

    just check          # or the keyless subset the repository's README names

If the repository has no `check` recipe, `just` lists what it does have.

## How this text is federated

The organization `.github` repository carries a byte-identical copy of this
file at its root. GitHub serves that copy as the contributing guide for every
repository in the organization that has no `CONTRIBUTING.md` of its own, so
one file covers every repository.

`meta` is the source. Its `just contributing-check` recipe fetches the
organization copy through `gh api` and fails on any byte difference, so a
change to this file that has not been mirrored is visible in `meta` CI.
Change this file first, then mirror the exact bytes to the `.github`
repository in a separate pull request.
