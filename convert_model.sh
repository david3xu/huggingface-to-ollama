#!/usr/bin/env bash

# Check for python/python3
if command -v python3 &>/dev/null; then
    PYTHON_CMD=python3
elif command -v python &>/dev/null; then
    PYTHON_CMD=python
else
    echo "Error: Neither python nor python3 found. Please ensure Python is installed."
    exit 1
fi

# Check for HF_TOKEN environment variable
if [ -z "$HF_TOKEN" ]; then
    echo "HF_TOKEN environment variable not found."
    echo "Please set your Hugging Face token using:"
    echo "export HF_TOKEN='your_token_here'"
    exit 1
fi

# Export the token for Python scripts to use
export HUGGING_FACE_HUB_TOKEN=$HF_TOKEN

# Install required packages
echo "Installing required packages..."
$PYTHON_CMD -m pip install --user -r requirements.txt

# Default values
MODEL_NAME=""
OUTPUT_DIR="./models"
OLLAMA_MODEL_NAME=""
SYSTEM_PROMPT="You are a helpful AI assistant."
TEMPERATURE=0.7
TOP_P=0.9
FORCE_UPDATE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL_NAME="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --ollama-name)
            OLLAMA_MODEL_NAME="$2"
            shift 2
            ;;
        --system-prompt)
            SYSTEM_PROMPT="$2"
            shift 2
            ;;
        --temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        --top-p)
            TOP_P="$2"
            shift 2
            ;;
        --force-update)
            FORCE_UPDATE=true
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$MODEL_NAME" ]; then
    echo "Error: --model parameter is required"
    exit 1
fi

if [ -z "$OLLAMA_MODEL_NAME" ]; then
    OLLAMA_MODEL_NAME=$(echo $MODEL_NAME | awk -F/ '{print $NF}')
fi

echo "Starting model conversion process..."
echo "Model: $MODEL_NAME"
echo "Output directory: $OUTPUT_DIR"
echo "Ollama model name: $OLLAMA_MODEL_NAME"

# Step 1: Check if GGUF model already exists
MODEL_FOLDER_NAME=$(echo $MODEL_NAME | awk -F/ '{print $NF}')
GGUF_PATH="$OUTPUT_DIR/$MODEL_FOLDER_NAME.gguf"

if [ -f "$GGUF_PATH" ] && [ "$FORCE_UPDATE" != "true" ]; then
    echo "GGUF model already exists at $GGUF_PATH"
    echo "To force update, run with --force-update flag"
    echo "Skipping download and conversion steps..."
else
    if [ -f "$GGUF_PATH" ]; then
        echo "Forcing update of existing model..."
        rm "$GGUF_PATH"
    fi
    echo "Downloading and converting model to GGUF..."
    GGUF_PATH=$($PYTHON_CMD scripts/download_model.py --model "$MODEL_NAME" --output "$OUTPUT_DIR")

    if [ $? -ne 0 ]; then
        echo "Error: Model download and conversion failed"
        exit 1
    fi
fi

# Step 2: Create Modelfile
echo "Creating Modelfile..."
$PYTHON_CMD scripts/create_modelfile.py \
    --gguf-path "$GGUF_PATH" \
    --output "." \
    --system-prompt "$SYSTEM_PROMPT" \
    --temperature "$TEMPERATURE" \
    --top-p "$TOP_P"

if [ $? -ne 0 ]; then
    echo "Error: Modelfile creation failed"
    exit 1
fi

# Step 3: Import to Ollama
echo "Importing model to Ollama..."
ollama create "$OLLAMA_MODEL_NAME" -f Modelfile

if [ $? -ne 0 ]; then
    echo "Error: Ollama import failed"
    exit 1
fi

echo "ollama pull $OLLAMA_MODEL_NAME"
echo "Conversion complete! You can now use the model with:"

