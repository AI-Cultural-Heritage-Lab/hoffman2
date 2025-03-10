import requests
import json
import os
import copy

PORT_NUM = 5000
SERVER_URL = "http://localhost:" + str(PORT_NUM)
CHAT_URL = SERVER_URL + "/chat"
USER_DIR = "/u/project/tpresner/shared/qsub/practice/{}".format(os.getenv('USER'))
INPUT_DIR = USER_DIR+"/input"
OUTPUT_DIR = USER_DIR+"/output"

# Create the directory if it does not exist
os.makedirs(USER_DIR, exist_ok=True)
os.makedirs(INPUT_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

def read_files_from_directory(directory):
    """
    Reads all files from a given directory and returns a dictionary
    where keys are filenames and values are the file contents.
    """
    file_contents = {}

    # Ensure the directory exists
    if not os.path.exists(directory):
        print(f"Directory does not exist: {directory}")
        return {}

    # Iterate through files in the directory
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)

        # Check if it's a file (not a directory)
        if os.path.isfile(file_path):
            try:
                with open(file_path, 'r') as file:
                    file_contents[filename] = file.read()
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

    return file_contents

def write_to_file(file_name, response):
    # Check if the request was successful
    if response.status_code == 200:
        response_json = response.json()
        print(response_json)
        raw_content = response_json["message"]["content"]
        print(raw_content)
        # Save response to file
        OUTPUT_FILE = OUTPUT_DIR+"/"+file_name
        with open(OUTPUT_FILE, "w") as f:
            f.write("Response from server: {}\n".format(raw_content))

        print("Saved response to {}".format(OUTPUT_FILE))

    else:
        print(f"Error {response.status_code}: {response.text}")

# Define the request payload (matches the curl command)
payload = {
    "model": "llama3.3:latest",
    "stream": False,
    "messages": [
        {
            "role": "system",
            "content": "Categorize the following food into one of these categories: Ravioli, Salad, Soup, or Sandwich"
        }
    ]
}

# Set the headers for JSON request
headers = {"Content-Type": "application/json"} 

try:
    # Send POST request to the Flask API
    file_contents = read_files_from_directory(INPUT_DIR)

    for filename, content in file_contents.items():
        print(f"\nProcessing file: {filename}")
        print(f"Content:\n{content}\n")
        payload_temp = copy.deepcopy(payload)
        payload_temp['messages'].append(
            {
                "role": "user",
                "content": content
            }
        )
        response = requests.post(CHAT_URL, headers=headers, json=payload_temp)

        write_to_file(filename, response)

except requests.exceptions.RequestException as e:
    error_msg = "Failed to connect to Flask server: {}".format(str(e))
    print(error_msg)
