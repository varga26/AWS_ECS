FROM ollama/ollama:latest

# Pre-download the qwen2.5:0.5b model into the container image
RUN nohup sh -c "ollama serve &" && sleep 5 && ollama pull qwen2.5:0.5b
