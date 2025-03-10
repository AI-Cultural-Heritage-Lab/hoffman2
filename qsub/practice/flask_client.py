import requests
import os

# Define Flask server details
FLASK_URL = "http://127.0.0.1:5000/hello"
OUTPUT_FILE = "/u/project/tpresner/shared/qsub/practice/exercise2_{}.txt".format(os.getenv('USER'))

try:
    # Send request to Flask server
    response = requests.get(FLASK_URL)
    
    # Save response to file
    with open(OUTPUT_FILE, "w") as f:
        f.write("Response from server: {}\n".format(response.text))

    print("Saved response to {}".format(OUTPUT_FILE))

except Exception as e:
    with open(OUTPUT_FILE, "w") as f:
        f.write("Failed to connect to Flask server: {}\n".format(str(e)))

    print("Failed to save response: {}".format(str(e)))
