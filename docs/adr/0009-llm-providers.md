# ADR-0009: LLM providers and model selection

- Status: Accepted
- Date: 2026-11-25

## Context

Lupka needs low-latency contextual translation without requiring a specific hosted provider. Users may supply their own key, run a local model, or use a platform-provided model. Language-pair support and local availability vary substantially.

## Decision

### Provider interface

Provide a universal OpenAI-compatible slot configured by `baseURL`, `apiKey`, and `model`. It covers OpenRouter, OpenAI, DeepSeek, Mistral, Groq, Gemini, and Ollama/LM Studio. Use a separate small adapter for Anthropic-native message formats. Ship provider presets in the config so the user only supplies a key.

The Kimi (Moonshot) preset supports:

- developer API `https://api.moonshot.ai/v1`, with a key from platform.kimi.ai;
- Kimi Code subscription endpoint `https://api.kimi.ai/coding/v1`, included with Pro, using subscription quota and its own model IDs and formally intended for coding tools.

The default Kimi model is **k3.1-pro with `reasoning_effort: low`**: K3 always reasons, and low provides popup-friendly speed. A highspeed variant is 2–3× faster at twice the price. Do not build around the K2 series: it is closed to new keys as of 2026-10-31 and is being retired through the end of 2026. Servers are in China, so RTT must be measured from the user’s network.

### Defaults without a key

Choose the default according to language-pair support:

- **Apple Foundation Models** (macOS 26+, M1+, Apple Intelligence enabled) provide free on-device inference and guided generation through `@Generable`. Supported languages are limited: Polish and Russian are not supported, and the framework throws `UnsupportedLanguageError`. FM alone is therefore unsuitable for pl→ru and similar pairs. Limits are 4096 tokens of context and knowledge through October 2023.
- As of WWDC26, `LanguageModelSession` is provider-independent and works with MLX models from Hugging Face. This provides one API while allowing the on-device model to be selected for the language pair.
- **Phi Silica** (3.3B, Windows App SDK) requires a Copilot+ PC with an NPU. The GPU path (RTX 30+, 6+ GB) is experimental; the model is unavailable in China and adds a generated-text watermark. Multilingual support is weak, and Ollama is the likely fallback for pl→ru.
- **Ollama/LM Studio** provide an offline fallback everywhere through the same OpenAI-compatible slot on localhost.

Use one on-device-first priority order everywhere:

```
system model supporting the pair (Apple FM / Phi Silica)
→ downloaded local model supporting the pair (MLX / Ollama)
→ external provider with the user's key
→ OCR mode without translation
```

Cloud translation requires the user's key. Platform-managed cloud inference without a user-supplied key, including Private Cloud Compute, is outside this policy.

### Model settings

Present three segments:

- **System** — Apple FM or Phi Silica through the platform backend;
- **Hugging Face** — local models;
- **External** — presets and custom OpenAI-compatible providers.

Check availability at launch and explain each state:

- unavailable system model → gray segment with “how to enable” guidance;
- unsupported language pair → yellow badge before translation rather than an error during translation;
- external provider → “test” button that sends one inexpensive request and shows a green checkmark on success.

The Hugging Face segment contains:

- a curated list of 2–3 verified models per language pair, including size and quality labels;
- a free-form HF repo ID field, validated before download for runtime-compatible weights (MLX on macOS, GGUF/ONNX on Windows), size, and license;
- 4-bit quantization by default;
- downloaded model management, including deletion through the app;
- platform runtimes: MLX on macOS, Windows ML / llama.cpp on Windows.

Reject an unsuitable model before downloading it and explain why it will not run.

At first launch, select the first available option from the priority order above. If no translation provider is available, use OCR mode with a “connect a model for translation” banner.

### Keys and speech

Store keys in macOS Keychain or Windows Credential Manager. Plaintext config is not allowed.

Use system speech for popup pronunciation: `AVSpeechSynthesizer` on macOS and SpeechSynthesis on Windows. It works offline without keys.

## Consequences

- Latency takes priority over model intelligence. The task is approximately 350 tokens and is within the capability of inexpensive models such as Haiku, GPT-mini, Gemini Flash, DeepSeek, or local 7B models.
- Users without any configuration still receive the best available option on their hardware.
- Model availability and language compatibility are visible before the user attempts a translation.
- Local model storage is managed by the app because downloaded models can occupy gigabytes.
