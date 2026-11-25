output "repository_full_name" {
  description = "Full GitHub repository name."
  value       = github_repository.lupka.full_name
}

output "repository_url" {
  description = "Repository web URL."
  value       = github_repository.lupka.html_url
}

output "default_branch" {
  description = "Configured default branch."
  value       = github_branch_default.main.branch
}
