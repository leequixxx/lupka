#!/usr/bin/env python3
import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
EXCLUDED_DIRECTORIES = {".git", ".build", ".terraform", "target"}
LINK_PATTERN = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
EXTERNAL_URL_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")


def markdown_files():
    files = []
    for directory, dirnames, filenames in os.walk(str(ROOT)):
        dirnames[:] = [
            name for name in dirnames if name not in EXCLUDED_DIRECTORIES
        ]
        for filename in filenames:
            if filename.endswith(".md"):
                files.append(Path(directory) / filename)
    return sorted(files)


def destination(raw_destination):
    value = raw_destination.strip()
    if value.startswith("<") and ">" in value:
        return value[1 : value.index(">")]
    return value.split()[0]


def heading_slug(heading):
    value = re.sub(r"[`*_~]", "", heading).strip().lower()
    value = re.sub(r"[^\w\- ]", "", value, flags=re.UNICODE)
    return re.sub(r" ", "-", value)


def check_links(files):
    errors = []
    checked = 0
    headings_by_file = {}
    for source in files:
        text = source.read_text(encoding="utf-8")
        for match in LINK_PATTERN.finditer(text):
            link = unquote(destination(match.group(1)))
            if not link or EXTERNAL_URL_PATTERN.match(link) or link.startswith("//"):
                continue
            path_part, _, fragment = link.partition("#")
            target = source if not path_part else (source.parent / path_part).resolve()
            try:
                target.relative_to(ROOT)
            except ValueError:
                errors.append(f"{source.relative_to(ROOT)}: link leaves repository: {link}")
                continue
            if not target.exists():
                errors.append(f"{source.relative_to(ROOT)}: broken link: {link}")
                continue
            checked += 1
            if not fragment or target.suffix != ".md":
                continue
            if target not in headings_by_file:
                target_text = target.read_text(encoding="utf-8")
                headings_by_file[target] = {
                    heading_slug(match.group(1))
                    for match in re.finditer(r"^#{1,6}\s+(.+?)\s*$", target_text, re.M)
                }
            if fragment not in headings_by_file[target]:
                errors.append(f"{source.relative_to(ROOT)}: missing anchor: {link}")
    return errors, checked


def check_adrs():
    errors = []
    adr_directory = ROOT / "docs" / "adr"
    paths = sorted(adr_directory.glob("[0-9][0-9][0-9][0-9]-*.md"))
    numbers = [int(path.name[:4]) for path in paths]
    if numbers != list(range(len(paths))):
        errors.append("docs/adr: ADR numbers must be contiguous from 0000")

    spec = (ROOT / "docs" / "spec.md").read_text(encoding="utf-8")
    index_numbers = [
        int(number)
        for number in re.findall(r"^\d+\. \[ADR-(\d{4}):", spec, re.M)
    ]
    if index_numbers != list(range(1, len(paths))):
        errors.append("docs/spec.md: ADR index must contain each numbered ADR once in order")

    for path in paths:
        number = int(path.name[:4])
        first_line = path.read_text(encoding="utf-8").splitlines()[0]
        match = re.match(r"^# ADR-(\d{4}): (.+)$", first_line)
        if not match:
            errors.append(f"{path.relative_to(ROOT)}: invalid ADR title")
            continue
        title = match.group(2)
        if int(match.group(1)) != number:
            errors.append(f"{path.relative_to(ROOT)}: filename and title numbers differ")
        first_name_token = path.name[5:].split("-")[0]
        if number and first_name_token not in title.lower():
            errors.append(f"{path.relative_to(ROOT)}: filename and title do not agree")
        if number and f"[ADR-{number:04d}: {title}](adr/{path.name})" not in spec:
            errors.append(f"docs/spec.md: index title does not match {path.name}")
        if spec.count(f"(adr/{path.name})") != 1:
            errors.append(f"docs/spec.md: expected exactly one link to {path.name}")
    return errors, max(len(paths) - 1, 0)


def main():
    files = markdown_files()
    link_errors, link_count = check_links(files)
    adr_errors, adr_count = check_adrs()
    errors = link_errors + adr_errors
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"Checked {len(files)} Markdown files, {link_count} local links, and {adr_count} ADRs.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
