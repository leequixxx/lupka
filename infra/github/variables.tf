variable "owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
  default     = "leequixxx"
}

variable "repository_name" {
  description = "GitHub repository name."
  type        = string
  default     = "lupka"
}

variable "description" {
  description = "Repository description shown on GitHub."
  type        = string
  default     = "Point at a word on your screen. Get a context-aware translation. Save it for learning."
}

variable "homepage_url" {
  description = "Repository homepage URL."
  type        = string
  default     = "https://lupka.io"
}

variable "visibility" {
  description = "Repository visibility: public or private."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "Visibility must be either public or private."
  }
}

variable "required_status_checks" {
  description = "GitHub Actions check names required before merging into main. Empty until CI exists."
  type        = list(string)
  default     = []
}
