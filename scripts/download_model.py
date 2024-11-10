from huggingface_hub import snapshot_download
import os
import argparse
import subprocess
import shutil

def download_and_convert_model(model_name, output_dir):
    """
    Download model from Hugging Face and convert to GGUF format using llama.cpp
    """
    print(f"Checking model {model_name}...")
    
    # Define paths
    model_folder_name = model_name.split('/')[-1]
    gguf_path = os.path.join(output_dir, f"{model_folder_name}.gguf")
    
    # Check if GGUF file already exists
    if os.path.exists(gguf_path):
        print(f"GGUF model already exists at {gguf_path}")
        print("Skipping download and conversion steps...")
        return gguf_path
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"Downloading {model_name}...")
    # Download model files
    local_dir = snapshot_download(
        repo_id=model_name,
        local_dir=os.path.join(output_dir, "temp_model")
    )
    
    # Clone llama.cpp repository if not exists
    llama_cpp_dir = "llama.cpp"
    if not os.path.exists(llama_cpp_dir):
        subprocess.run(["git", "clone", "https://github.com/ggerganov/llama.cpp.git"], check=True)
    
    # Install llama.cpp requirements
    subprocess.run(["pip", "install", "-r", f"{llama_cpp_dir}/requirements.txt"], check=True)
    
    print(f"Converting model to GGUF format...")
    # Convert using llama.cpp convert script
    convert_cmd = [
        "python3",
        f"{llama_cpp_dir}/convert_hf_to_gguf.py",
        local_dir,
        "--outfile", gguf_path,
        "--outtype", "q4_k_m"
    ]
    
    try:
        subprocess.run(convert_cmd, check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Conversion failed: {e}")
    
    # Cleanup temporary files
    shutil.rmtree(local_dir)
    
    print(f"Model converted and saved to {gguf_path}")
    return gguf_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download and convert Hugging Face model to GGUF")
    parser.add_argument("--model", required=True, help="Hugging Face model name")
    parser.add_argument("--output", required=True, help="Output directory path")
    
    args = parser.parse_args()
    download_and_convert_model(args.model, args.output)
