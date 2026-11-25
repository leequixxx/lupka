provider "github" {
  owner = var.owner
}

resource "github_repository" "lupka" {
  name         = var.repository_name
  description  = var.description
  homepage_url = var.homepage_url
  visibility   = var.visibility

  auto_init       = false
  has_issues      = true
  has_projects    = true
  has_discussions = false
  has_wiki        = false

  allow_squash_merge          = true
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_auto_merge            = false
  delete_branch_on_merge      = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
}

resource "github_branch_default" "main" {
  repository = github_repository.lupka.name
  branch     = "main"
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.lupka.node_id
  pattern       = github_branch_default.main.branch

  enforce_admins          = true
  required_linear_history = true
  allows_deletions        = false
  allows_force_pushes     = false

  required_status_checks {
    strict   = true
    contexts = var.required_status_checks
  }

  required_pull_request_reviews {
    required_approving_review_count = 0
    dismiss_stale_reviews           = true
  }
}
