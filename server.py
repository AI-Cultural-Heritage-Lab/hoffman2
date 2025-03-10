from flask import Flask, request, jsonify
import requests
import random
import psutil
import os

# print("Checking environment variables in qsub job...\n")
# for key, value in os.environ.items():
#     print(f"{key}={value}")

# # Specific check for JOB_ID
# print("\nJOB_ID:", os.environ.get("JOB_ID"))
# print("ENVIRONMENT:", os.environ.get("ENVIRONMENT"))

def is_running_under_qsub():
    return "JOB_ID" in os.environ

app = Flask(__name__)

OLLAMA_URL = "http://localhost:11434/api/chat"

def check_port_in_use(port):
    # Iterate through all the current active connections
    for conn in psutil.net_connections(kind='inet'):
        if conn.laddr.port == port:  # Check if the port is being used
            return True
    return False

def get_port():
    while True:
        try:
            # Prompt the user for a port number
            port_input = input("Enter the port number to run the Flask server (default: 5000): ").strip()
            
            # If input is empty, use the default port 5000
            if not port_input:
                port = 5000
            else:
                port = int(port_input)  # Convert the input to an integer

            # Check if the port is within the valid range (1024 to 65535)
            if 1024 <= port <= 65535:
                if check_port_in_use(port):  # Check if port is already in use
                    print(f"Port {port} is already in use. Please choose another port.")
                else:
                    break  # Exit the loop if the port is valid and available
            else:
                print("Please enter a valid port number between 1024 and 65535.")
        except ValueError:
            print("Invalid input. Please enter a numeric port.")
    return  port_input


@app.route("/chat", methods=["POST"])
def chat():
    try:
        # Get JSON input from the request
        user_input = request.json

        # Send request to Ollama API
        response = requests.post(OLLAMA_URL, json=user_input)

        # Check if Ollama API response is successful
        if response.status_code == 200:
            return jsonify(response.json()), 200
        else:
            return jsonify({"error": "Failed to fetch response from Ollama", "details": response.text}), response.status_code

    except Exception as e:
        return jsonify({"error": "An error occurred", "details": str(e)}), 500
    
@app.route('/health', methods=['GET'])
def check_health():
    return jsonify({"status": "running"})

if __name__ == "__main__":
    # Run Flask on the user-specified port

    if is_running_under_qsub():
        print("Running inside a qsub job.")
        # Normal behavior
        app.run(host="0.0.0.0", port=5000, debug=False)

    else:
        print("Running normally (not inside qsub).")
        # Modify Flask server behavior for qsub
        app.run(host="0.0.0.0", port=get_port(), debug=False)


