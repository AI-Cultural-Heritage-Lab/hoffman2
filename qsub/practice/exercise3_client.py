import requests
import json
import os

PORT_NUM = 5000
SERVER_URL = "http://localhost:" + str(PORT_NUM)
CHAT_URL = SERVER_URL + "/chat"
OUTPUT_FILE = "/u/project/tpresner/shared/qsub/practice/exercise3_{}.txt".format(os.getenv('USER'))

# Define the request payload (matches the curl command)
payload = {
    "model": "llama3.3:latest",
    "stream": False,
    "messages": [
        {
            "role": "user",
            "content": "Hi my name is nancy, I'm 25, and I like walking my dog. I also like eating avocados and sleeping."
        }
    ]
}

# Set the headers for JSON request
headers = {"Content-Type": "application/json"}

try:
    # Send POST request to the Flask API
    response = requests.post(CHAT_URL, headers=headers, json=payload)

    # Check if the request was successful
    if response.status_code == 200:
        response_json = response.json()
        raw_content = response_json["message"]["content"]
        print(raw_content)
        # Save response to file
        with open(OUTPUT_FILE, "w") as f:
            f.write("Response from server: {}\n".format(raw_content))

        print("Saved response to {}".format(OUTPUT_FILE))

    else:
        print(f"Error {response.status_code}: {response.text}")

except requests.exceptions.RequestException as e:
    error_msg = "Failed to connect to Flask server: {}".format(str(e))
    print(error_msg)

    # Save failure message to file
    with open(OUTPUT_FILE, "w") as f:
        f.write(error_msg + "\n")


   
