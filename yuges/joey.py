import os
import requests

# Function to download an image from a URL and save it locally with a specified name
def download_image(url, save_directory, filename):
    try:
        # Get the image content from the URL
        response = requests.get(url, stream=True)
        response.raise_for_status()  # Check if the request was successful

        # Create the directory if it doesn't exist
        if not os.path.exists(save_directory):
            os.makedirs(save_directory)

        # Save the image with the specified filename in the save directory
        image_path = os.path.join(save_directory, f"{filename}.jpg")  # Save with .jpg extension
        with open(image_path, 'wb') as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)

        print(f"Downloaded: {filename}.jpg")
    except requests.exceptions.RequestException as e:
        print(f"Failed to download {url}: {e}")

# Ask the user for the input file containing image URLs and names
input_filename = input("Please enter the name of the input file containing the names and URLs (e.g., 'image_list.txt'): ")

# Directory to save the downloaded images
save_directory = "downloaded_images"

# Read name and image URLs from the input file
try:
    with open(input_filename, "r", encoding="utf-8") as file:  # Use utf-8 encoding to handle most special characters
        for line in file:
            # Strip the line of extra whitespace and unwanted escape characters
            line = line.strip().replace('\\"', '').replace('"', '')  # Remove unwanted characters

            # Skip empty lines
            if not line:
                continue

            # Split the line by pipe (|) to get the name and URL
            parts = line.split('|')  # Using | as the separator

            # Ensure that exactly two parts (name and URL) are present
            if len(parts) != 2:
                print(f"Skipping invalid line: {line}")
                continue

            name, url = parts  # Unpack the name and URL

            # Download the image and save it with the specified name
            download_image(url.strip(), save_directory, name.strip())

    print("All images have been downloaded.")

except FileNotFoundError:
    print(f"The file '{input_filename}' was not found. Please ensure the file is in the same directory as the script.")
except Exception as e:
    print(f"An error occurred: {e}")