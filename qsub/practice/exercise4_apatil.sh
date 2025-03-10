#!/bin/bash

# Run in the current working directory
#$ -cwd

# Set resource limits
#$ -l h_data=10G              # Request 10GB RAM
#$ -l gpu                     # Request a GPU
#$ -l A100                    # Specify NVIDIA A100 GPU
#$ -l cuda=1                  # Ensure CUDA is enabled
#$ -l h_rt=3:00:00            # Max runtime: 3 hours

# Handle job output
#$ -o /u/project/tpresner/shared/qsub/logs/$USER/joblog.$JOB_ID
#$ -j y  # Merge standard error and output into one log file

# Email notifications
#$ -m bea  # Notify on job (b)egin, (e)nd, and (a)bort

# Enable modules to be loaded
source /u/local/Modules/4.7.0/gcc-4.8.5/init/modules.sh

# Change to the shared project directory
cd /u/project/tpresner/shared/qsub/practice || { echo "Failed to change directory"; exit 1; } 

echo "Running job on Hoffman2 with Job ID: $JOB_ID"

# Load system-required Python 3.9.6 module
module load python/3.9.6

# Preserve JOB_ID before activating Conda
export QSUB_JOB_ID=$JOB_ID

# Load Anaconda 2023.03 module
module load anaconda3/2023.03

# Print confirmation
MODULES_LOADED=$(module list 2>&1)
echo "Loaded Modules:"
echo "$MODULES_LOADED"
echo "Python 3.9.6 and Anaconda3 2023.03 modules loaded"

echo ""

# Set the OLLAMA_MODELS environment variable to the team group directory
export OLLAMA_MODELS="/u/project/tpresner/shared/"

# Load Apptainer
module load apptainer

# Verify Apptainer is available
if ! command -v apptainer &> /dev/null; then
    echo "Error: Apptainer failed to load."
    exit 1
else
    echo "Apptainer loaded successfully!"
    apptainer --version
fi

# Load Ollama
apptainer instance run --nv $H2_CONTAINER_LOC/h2-ollama.sif myollama
echo "Started Apptainer instance: myollama"
ps aux | grep apptainer
apptainer instance list

echo ""

# Activate Conda environment
# source /u/home/$USER/miniconda3/etc/profile.d/conda.sh  # Ensure Conda is initialized
conda activate /u/project/tpresner/shared/mypython  # Activate the Conda environment
echo "Conda environment activated successfully"

echo ""

# Verify the active Python environment
echo "Using Python from: $(which python)"
python --version

echo ""

# Start Flask server in the background
python /u/project/tpresner/shared/server.py &  
FLASK_PID=$!  # Store the PID of the Flask server
echo "Flask server started with PID $FLASK_PID"

echo ""

# Wait for Flask to initialize
sleep 10

# Check if Flask is actually running
if ! ps -p $FLASK_PID > /dev/null; then
    echo "Flask server failed to start. Exiting."
    exit 1
fi

## TODO: Update client Python script name 
# Run the client script to send a request to Flask
if python /u/project/tpresner/shared/qsub/practice/exercise4_client_apatil.py; then
    echo "Client script executed. Output saved to /u/project/tpresner/shared/qsub/practice/$USER/output"
else
    echo "Client script failed to execute. Check Flask server logs."
fi

# Kill Flask server after client script finishes
echo "Stopping Flask server with PID $FLASK_PID"
kill $FLASK_PID 

# Ensure Flask is fully stopped 
wait $FLASK_PID 2>/dev/null
echo "Flask server stopped successfully."

apptainer instance stop myollama
echo "myollama apptainer instance stopped."
