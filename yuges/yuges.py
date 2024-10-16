import re

# Ask the user for the filename
input_filename = input("Please enter the name of the input file (e.g., 'input.txt'): ")
output_filename = input("Please enter the name of the output file (e.g., 'output.txt'): ")

# Define regex patterns to match the ID and name lines
id_pattern = re.compile(r'"id": (\d+),')  # Captures the ID number
name_pattern = re.compile(r'"name": "(.+)",')  # Captures the name string

# Initialize variables to store the current ID and name and a list for the output
current_id = None
current_name = None
last_id = None
output_lines = []

# Open the input file and output file with UTF-8 encoding
try:
    with open(input_filename, "r", encoding="utf-8") as infile, open(output_filename, "w", encoding="utf-8") as outfile:
        for line in infile:
            # Check if the line matches the "id" pattern
            id_match = id_pattern.search(line)
            if id_match:
                current_id = id_match.group(1)  # Extract the ID number

            # Check if the line matches the "name" pattern
            name_match = name_pattern.search(line)
            if name_match:
                current_name = name_match.group(1)  # Extract the name

                # Write the ID and name if a new ID is found (ignore duplicates)
                if current_id != last_id:
                    output_lines.append(f"{current_id}, {current_name}")
                    last_id = current_id  # Update the last_id to track duplicates

        # Write the output lines to the output file, each on a new line
        outfile.write("\n".join(output_lines))

    # Print the results to the console
    print(f"Processed {len(output_lines)} unique 'id' and 'name' pairs.")
    print(f"Filtered data has been written to {output_filename}")

except FileNotFoundError:
    print(f"The file '{input_filename}' was not found. Please ensure the file is in the same directory as the script.")
except UnicodeDecodeError:
    print(f"Error: Unable to decode the file '{input_filename}'. Try using a different encoding.")