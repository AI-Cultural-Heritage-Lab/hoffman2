#!/bin/bash
# Set the working directory to the script's directory (ensure it's always the same)
cd "$(dirname "$0")" || exit
export OLLAMA_MODELS=$PWD

# Function to start Ollama container
start_ollama_container() {
    apptainer instance run --nv $H2_CONTAINER_LOC/h2-ollama.sif myollama
}

# Function to start Ollama web UI
start_ollama_webui() {
    apptainer instance run --nv $H2_CONTAINER_LOC/h2-ollama.sif myollama openwebui
}

# Function to check running instances
check_running_instance() {
    apptainer instance list
}

# Function to view instance logs
view_instance_logs() {
    apptainer instance list --logs
}

# Function to stop Ollama instance
stop_ollama_instance() {
    apptainer instance stop myollama
}

# Function to pull a model
pull_model() {
    read -p "Please enter the name of the model to pull: " model_name
    apptainer exec instance://myollama ollama pull "$model_name"
}

# Function to run a model
run_model() {
    echo "Fetching available models..."
    
    # Extract the first column (model names) using awk
    models=$(apptainer exec instance://myollama ollama list | awk 'NR>1 {print $1}')  # Skip header and print the first column
    
    # Print the model names
    echo "$models"
    
    echo "Please choose a model to run:"
    PS3="Enter your choice (1-$(echo "$models" | wc -l)): "
    
    # Create a select menu for the models
    select model in $models; do
        if [[ -n "$model" ]]; then
            apptainer exec instance://myollama ollama run "$model"
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
}

# Main menu function
show_menu() {
    echo ""
    echo "Ollama Container Management"
    echo "==========================="
    echo "a) Start Ollama Container"
    echo "b) Start Ollama WebUI"
    echo "c) Check Running Instances"
    echo "d) View Instance Logs"
    echo "e) Stop Ollama Instance"
    echo "f) Pull a Model"
    echo "g) Run a Model"
    echo "h) Exit - Re-start this interface later by running ./ollama.sh in your terminal"
    echo "==========================="
    read -p "Select an option [a-h]: " option

    case $option in
        a) start_ollama_container ;;
        b) start_ollama_webui ;;
        c) check_running_instance ;;
        d) view_instance_logs ;;
        e) stop_ollama_instance ;;
        f) pull_model ;;
        g) run_model ;;
        h) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    echo ""
}

# Run the meanu until the user chooses to exit
while true; do
    show_menu
done

