# Security Policy

## Project status

Lupka has no stable releases yet. Security fixes apply to the default development branch once implementation begins. There is currently no supported release line or guaranteed response timeline.

## Reporting a vulnerability

Please report suspected vulnerabilities privately through [GitHub Security Advisories](https://github.com/leequixxx/lupka/security/advisories/new).

Do not open a public issue for a vulnerability. If private reporting is unavailable, contact the repository owner through the contact methods listed on [the maintainer’s GitHub profile](https://github.com/leequixxx) before publishing details.

Include, where applicable:

- the affected commit or version;
- platform and OS version;
- reproduction steps;
- expected security impact;
- a minimal proof of concept.

Do not include real API keys, personal screenshots, private OCR output, or other user data. Use synthetic examples and redact sensitive values.

## Areas of particular concern

- screen capture, screenshot cropping, and image retention;
- OCR output and prompt contents sent to LLM providers;
- API key handling and system credential storage;
- arbitrary file writes through backlog sinks;
- untrusted preset registry content and validation;
- process suspension and guaranteed process resume;
- telemetry or unintended disclosure of window titles, prompts, application lists, or presets.

## Disclosure

Please allow maintainers to investigate and prepare a fix before public disclosure. Disclosure timing should be coordinated in the private advisory, taking issue severity and user impact into account.
