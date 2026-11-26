# GitHub repository infrastructure

This OpenTofu configuration manages the Lupka GitHub repository and `main` branch protection:

- squash-only merging with PR title/body as the squash template;
- automatic deletion of merged branches;
- `main` as the default branch;
- required pull requests and linear history;
- required `Documentation`, `OpenTofu`, and `Rust and macOS` status checks;
- up-to-date branches through strict status-check policy;
- no force pushes or branch deletion;
- enforcement for administrators.

Projects v2 boards, GitHub Actions secrets, and signing credentials are not managed here. Do not store tokens or secrets in Terraform files or state committed to the repository.

## Prerequisites

- OpenTofu 1.6 or newer.
- A GitHub token in `GITHUB_TOKEN` with permission to administer the repository.
- An existing `main` branch before applying branch settings.

Initialize the provider:

```bash
cd infra/github
tofu init
```

Validate the configuration:

```bash
tofu fmt -check
tofu validate
tofu plan
```

## Import an existing repository

If `leequixxx/lupka` already exists, import it before applying any changes:

```bash
tofu import github_repository.lupka lupka
tofu plan
```

The provider expects the repository name without the owner prefix.

Review the plan carefully. Apply only after the initial documentation commit has created `main`:

```bash
tofu apply
```

## Create a new repository

Create only the repository resource first:

```bash
tofu apply -target=github_repository.lupka
```

Push the initial `#1` documentation commit to `main`, then configure the default branch and protection:

```bash
tofu plan
tofu apply
```

Do not run a full apply before `main` exists; branch resources depend on it.

## Required status checks

The required checks are `Documentation`, `OpenTofu`, and `Rust and macOS`. Their values in `infra/github/variables.tf` must exactly match the job names in `.github/workflows/ci.yml`. After changing CI, verify the names on a pull request, review the OpenTofu plan, and let a maintainer apply the reviewed configuration.

## Change workflow

1. Change the configuration through the normal issue and pull request workflow.
2. Run `tofu fmt -check` and `tofu validate`.
3. Review the configuration and generated plan.
4. After merge, a maintainer applies the reviewed configuration from the current `main` using an administrative token.

Do not run `tofu apply` from an unreviewed branch. Local state, plans, and provider caches are ignored by Git.
