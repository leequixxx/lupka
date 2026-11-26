# Contributing to Lupka

Thanks for helping build Lupka. Contributions to code, documentation, architecture, testing, and issue triage are welcome.

## Before you start

Lupka is at an early implementation stage. The repository contains a Rust workspace and macOS Swift package bootstrap, but no working lookup flow, stable release, or installation path. Use the canonical development commands documented in `AGENTS.md`.

- Search existing issues and pull requests before opening another one.
- Read `docs/spec.md` and the ADRs relevant to your change.
- Open an issue before substantial implementation work or an architectural change. This helps avoid conflicting approaches and duplicate ADRs.

## Issues and project board

Use **one GitHub issue → one branch → one pull request → one squash commit in `main`**.

The project board uses these columns:

```
Backlog → Ready → In Progress → In Review → Done
```

An issue is **Ready** when it has:

- a clear problem and expected outcome;
- scope and explicit out-of-scope boundaries where useful;
- testable acceptance criteria;
- a validation approach;
- links to relevant ADRs or a note that a new ADR is required.

Keep at most one issue In Progress per contributor or agent. Split work that cannot be reviewed and merged as one coherent change.

## Branches, commits, and pull requests

Use the GitHub issue number without a `TICKET-` prefix:

```text
Issue:  #123
Branch: 123-macos-hotkey
Commit: feat(#123): register global hotkey
PR:     #123: Add macOS global hotkey
Squash: #123: Add macOS global hotkey
```

- Branch names use `123` or `123-short-slug`; do not include `#` in the Git ref.
- Development commits use `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `build`, `ci`, or `chore`, followed by the issue number: `feat(#123): ...`.
- Write commit subjects in English and use the imperative mood.
- The PR body contains `Closes #123` and the validation performed.
- The PR and squash titles use the **issue** number. Do not rely on the automatically suggested PR number: issues and PRs have different numbers.
- Keep the PR focused on its single linked issue.

### Contribution workflow

1. Create the branch from the current `main`.
2. Make the smallest coherent change that satisfies the acceptance criteria.
3. Rebase the branch on the current `main` before review.
4. Validate the change and update relevant documentation and ADRs.
5. Open a pull request titled `#123: ...`, with `Closes #123` in the body.
6. After review and required checks, squash merge and delete the branch.

Do not push directly to `main` or reuse a branch after a squash merge. The intended repository settings require pull requests, squash-only merging, linear history, up-to-date branches, required CI checks once available, and automatic head-branch deletion.

### Reopened and follow-up work

- Reopen the same issue only when it was closed by mistake or its PR has not been merged.
- Once a squash commit has landed in `main`, create a new issue for corrections, regressions, or additional scope.
- Link related work with `Follow-up to #123` or `Regression of #123`.

### Parallel contributors and agents

Each contributor or agent works on one issue and branch at a time. Parallel agents use separate Git worktrees and must not edit another session’s branch. Assign new ADR numbers in the issue before parallel work begins, and inspect the current file tree before creating or renaming ADRs.

Use English for documentation, comments, commits, issues, pull requests, and discussion. Language-specific prompt values, translations, and learning content remain in their intended languages.

## Releases

Lupka uses semantic versioning and trunk-based releases from `main`. Follow `RELEASING.md` for release issues, version PRs, annotated tags, packaging, and publication. Release PRs use `Refs #123` rather than `Closes #123` so the release issue remains open until the release is published.

## Documentation changes

- Keep `README.md` honest about implemented behavior and project status.
- Keep `docs/spec.md` as an overview and ADR index, not a duplicate of complete ADRs.
- Update affected links and cross-references when moving, renaming, or removing content.
- Check that local Markdown links resolve.
- Do not add personal circumstances, business plans, or roadmap commentary to technical documents.

## Architecture decisions

- Use `docs/adr/0000-template.md` for a new decision.
- Record one decision per ADR with a contiguous number, matching filename and title, status, and date.
- Do not create a duplicate ADR for an existing decision. Clarify the current ADR when needed; create a superseding ADR when replacing a decision.
- Add every new ADR to `docs/spec.md` and update affected references.

## Code contributions

For implementation changes:

- Keep shared business logic in the Rust core and OS integration in native shells.
- Preserve the small, flat uniffi boundary: data structures and strings, no callbacks or shared ownership.
- Match the surrounding project conventions and existing dependency choices.
- Add tests for behavior changed by the contribution and run the project’s standard build and test commands.
- Update `AGENTS.md` when introducing or changing canonical build, test, lint, or run commands.

For process-suspension changes, test every resume path: popup close, application exit, signals, errors, and watchdog recovery.

## Repository infrastructure

GitHub repository and branch settings live in `infra/github/`. Follow the import, planning, and apply rules in `infra/github/README.md`. Validate changes with:

```bash
cd infra/github
tofu fmt -check
tofu validate
```

Do not commit Terraform state, plans, provider caches, or credentials. Do not apply unreviewed configuration.

## AI-assisted contributions

AI assistance is welcome, but the contributor remains responsible for the result. Review generated changes, understand what you submit, run the relevant checks, and remove unrelated output. Do not send private code, credentials, screenshots, or user data to third-party AI services without permission.

## Security and privacy

- Never commit API keys, credentials, private screenshots, OCR output, or personal user data.
- Redact sensitive information from logs and screenshots attached to public issues.
- Do not publicly disclose suspected vulnerabilities. Follow `SECURITY.md` instead.
- Do not add telemetry or silent uploading of screenshots, window titles, prompts, application lists, or local presets.

## License

By contributing, you agree that your contributions are licensed under the repository’s [MIT License](LICENSE).
