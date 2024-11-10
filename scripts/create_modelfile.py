import argparse
import os

def create_modelfile(gguf_path, output_dir, system_prompt="", temperature=0.7, top_p=0.9):
    """
    Update or create Ollama Modelfile for GGUF model
    """
    modelfile_path = os.path.join(output_dir, "Modelfile")
    
    # Create new Modelfile content
    modelfile_content = f"""FROM {gguf_path}

PARAMETER temperature {temperature}
PARAMETER top_p {top_p}
PARAMETER stop "<|endoftext|>"

SYSTEM "{system_prompt}"

TEMPLATE "{{{{.System}}}}{{{{.Prompt}}}}"
"""
    
    # Write the Modelfile
    with open(modelfile_path, "w") as f:
        f.write(modelfile_content)
    
    print(f"Modelfile created at {modelfile_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create Ollama Modelfile")
    parser.add_argument("--model", required=False, help="Model name")
    parser.add_argument("--gguf-path", required=True, help="Path to GGUF model file")
    parser.add_argument("--output", required=True, help="Output directory path")
    parser.add_argument("--system-prompt", default="", help="System prompt")
    parser.add_argument("--temperature", type=float, default=0.7, help="Temperature parameter")
    parser.add_argument("--top-p", type=float, default=0.9, help="Top-p parameter")
    
    args = parser.parse_args()
    create_modelfile(args.gguf_path, args.output, args.system_prompt, args.temperature, args.top_p)
