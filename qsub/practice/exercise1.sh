# Run in the current working directory
#$ -cwd

# Set resource limits (matching qrsh settings)
#$ -l h_rt=3:00:00   # Max runtime: 3 hours
#$ -l h_data=4G      # Request 4GB memory

# Handle job output (Save logs to shared directory)
#$ -o /u/project/tpresner/shared/qsub/logs/$USER/joblog.$JOB_ID
#$ -j y  # Merge standard error and output into one log file

# Email notifications (Modify as needed)
#$ -m bea                    # Notify on job (b)egin, (e)nd, and (a)bort

# Change to the shared project directory
cd /u/project/tpresner/shared/ || { echo "Failed to change directory"; exit 1; } 

echo "Running job on Hoffman2 with Job ID: $JOB_ID"

# Ensure log folder exists
mkdir -p /u/project/tpresner/shared/qsub/logs/$USER

# Write message to a file
echo "Submitted my first qsub command at $(date '+%Y-%m-%d %H:%M:%S')! Woohoo!" > /u/project/tpresner/shared/qsub/practice/exercise1_$USER.txt

# Print confirmation message to log
echo "Job completed successfully. Output written to /u/project/tpresner/shared/qsub/practice/exercise1_$USER.txt"