#!/bin/bash

# Run in the current working directory
#$ -cwd

# Set resource limits
#$ -l h_rt=3:00:00   # Max runtime: 3 hours
#$ -l h_data=4G      # Request 4GB memory

# Handle job output
#$ -o /u/project/tpresner/shared/qsub/logs/$USER/joblog.$JOB_ID
#$ -j y  # Merge standard error and output into one log file

# Email notifications
#$ -m bea  # Notify on job (b)egin, (e)nd, and (a)bort

source /u/local/Modules/4.7.0/gcc-4.8.5/init/modules.sh

# Change to the shared project directory
cd /u/project/tpresner/shared/qsub/practice/ || { echo "Failed to change directory"; exit 1; } 

echo "Running job on Hoffman2 with Job ID: $JOB_ID"

# Load system-required Python 3.9.6 module
module load python/3.9.6

# Load Anaconda 2023.03 module
module load anaconda3/2023.03

# Print confirmation
MODULES_LOADED=$(module list 2>&1)
echo "Loaded Modules:"
echo "$MODULES_LOADED"
echo "Python 3.9.6 and Anaconda3 2023.03 modules loaded"

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
python flask_server.py &  
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

# Run the client script to send a request to Flask
if python flask_client.py; then
    echo "Client script executed. Output saved to /u/project/tpresner/shared/qsub/practice/exercise2_$USER.txt"
else
    echo "Client script failed to execute. Check Flask server logs."
fi

# Kill Flask server after client script finishes
echo "Stopping Flask server with PID $FLASK_PID"
kill $FLASK_PID

# Ensure Flask is fully stopped
wait $FLASK_PID 2>/dev/null
echo "Flask server stopped successfully."