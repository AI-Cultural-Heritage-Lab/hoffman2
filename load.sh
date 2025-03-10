#!/bin/bash
echo "Loading relevant modules..."

# Load Python 3.9.6 module
module load python/3.9.6

# Load Anaconda3 2023.03 module
module load anaconda3/2023.03

# Print confirmation
echo "1. Python 3.9.6 and Anaconda3 2023.03 module loaded"

# Set the OLLAMA_MODELS environment variable to the current working directory
export OLLAMA_MODELS=$PWD
echo "2. Referencing tpresner shared directory for Ollama models"

# Load apptainer module
module load apptainer 

echo "3. apptainer module for Ollama loaded"

