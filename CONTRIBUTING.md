# Contributing

Great Falls Tool Bus is a member-run club. To get involved, see
[greatfallstoolbus.org/wants](https://greatfallstoolbus.org/wants) or reach
us at [greatfallstoolbus.org/contact](https://greatfallstoolbus.org/contact).

This file is the contributing contract for every repository in the
Great Falls Tool Bus organization. The source of record is
`steering/CONTRIBUTING.md` in the private `meta` repository; the copy in the
organization `.github` repository is federated from it and must stay
byte-identical. Change it in `meta` first.

## Source access

Our source repositories are private. Access is granted by an org owner.
Contributors join a single team at Triage. No team and no direct collaborator
grant holds Write, Maintain or Admin except the owner; Write is granted one
person at a time and one repository at a time, after the account setup below
is verified.

## Account setup

- Enable two-factor authentication on your GitHub account before anything
  else.
- Upload an SSH authentication key and, separately, a signing key (GPG is an
  accepted alternative). Enable vigilant mode.
- Sign every commit. An unsigned commit is not landed.
- Org members receive the private onboarding guide from an owner once access
  is granted.

## Fork first

Work happens on a fork of the repository, not on a branch in it.

1. Fork the repository under your own account.
2. Create a branch on your fork for each change.
3. Open a pull request from your fork into the organization repository's
   `main` branch.
4. Keep the pull request small and say plainly what it does and what evidence
   supports it. "Deployed", "verified" and "green" each need a receipt.

Owners and Write holders follow the same fork-first flow for ordinary changes.
A branch pushed directly to an organization repository is reserved for release
mechanics and for landing on behalf of a contributor whose fork cannot run
checks.

## What holds the line

The organization is on GitHub Free with private repositories. There is no
branch protection, no ruleset, no required signature and no required workflow.
Continuous integration checks are signals, not gates. What actually holds the
line is the permission model (only the owner can merge), signed commits, and
an exact-head review by someone other than the author.

Pull requests from forks into private repositories run no workflows today.
The pinned spoke workflow in `ci-templates` skips a pull request whose head
repository differs from the base repository; a patch admitting head
repositories owned by the org owner's account is in flight. Until a fork's
pull request runs checks, the reviewer runs the repository's keyless `just`
recipe locally and records what they observed in the review.

## Working here

- Where a repository has a Justfile, `just` is the only entrypoint. Do not
  call the underlying tools directly. If something you need has no recipe,
  that is a gap to raise, not a reason to bypass `just`.
- Work is tracked in Linear. Reference the issue in the pull request.
- Review is by someone other than the author. Approve, request changes, or
  say you are not the right reviewer; all three are useful.

## Landing

Pull requests land by squash. The squash commit subject is the pull request
title, so write the title as the commit subject you want on `main`.

In `greatfallstoolbus.org`, the release workflow matches the landed commit
subject against `^release: vX.Y.Z$`. A release pull request is titled exactly
`release: vX.Y.Z` and nothing else; a trailing pull request number or any
other suffix is rejected by that pattern.

## Commits

Commit as yourself. Do not add AI-attribution trailers (for example
`Co-Authored-By`) to commits or pull requests, and do not prefix pull request
titles with a tool name.
