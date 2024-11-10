# Hugging Face to Ollama Model Converter

A tool to convert Hugging Face models to Ollama format for local use.

## Prerequisites

- Python 3.8+
- Ollama
- Git
- Hugging Face account and access token

## Quick Start

1. Set your Hugging Face token:
```bash
export HF_TOKEN='your_huggingface_token_here'
```

2. Make the conversion script executable:
```bash
chmod +x convert_model.sh
```

3. Convert and import a model:
```bash
./convert_model.sh \
    --model "David-Xu/cira-7b-dpo-lora-merge-v0.1" \
    --ollama-name "astronomy-assistant" \
    --temperature 0.2 \
    --top-p 0.9
```

4. Run the model:
```bash
ollama run astronomy-assistant "What is a black hole?"
```

## License

MIT
