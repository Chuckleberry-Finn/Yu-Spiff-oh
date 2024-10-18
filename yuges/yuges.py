import re

# Ask the user for the filename
input_filename = 'cardinfo.txt'
output_filename = input("Please enter the name of the output file (e.g., 'output.txt'): ")

# Define regex patterns to match the ID, name, and card sets
id_pattern = re.compile(r'"id": (\d+),')  # Captures the ID number
name_pattern = re.compile(r'"name": "(.+)",')  # Captures the name string
set_rarity_pattern = re.compile(r'"set_rarity": "(.+)"')  # Captures the set rarity

# Define the list of allowed rarities and their average percentage weights
rarity_weights = {
    "Common": 65,
    "Uncommon": 40,
    "Rare": 17.5,
    "Super Rare": 8.5,
    "Ultra Rare": 4,
    "Secret Rare": 1.5,
    "Ultimate Rare": 0.5
}

allowed_rarities = list(rarity_weights.keys())  # Use the keys from the weights as allowed rarities

# Initialize variables to store the current ID, name, and sets
current_id = None
current_name = None
rarity_count = {}  # Dictionary to count rarities
output_lines = []

inside_card_sets = False  # Track when inside the card sets section

# Function to determine the closest rarity based on average percentage
def closest_rarity(average):
    closest_rarity_name = min(rarity_weights, key=lambda rarity: abs(rarity_weights[rarity] - average))
    return closest_rarity_name

# Open the input file and output file with UTF-8 encoding
try:
    with open(input_filename, "r", encoding="utf-8") as infile, open(output_filename, "w", encoding="utf-8") as outfile:
        for line in infile:
            line = line.strip()  # Remove leading/trailing whitespace
            print(f"Processing line: {line}")  # Debug: Print the current line

            # Ignore the start of the header
            if line == '"data": [' or line == '],':
                print("Skipping header or footer.")  # Debug: Header/footer skip
                continue

            # Check if the line matches the "id" pattern
            id_match = id_pattern.search(line)
            if id_match:
                current_id = id_match.group(1)  # Extract the ID number
                print(f"Found ID: {current_id}")  # Debug: Print the found ID

            # Check if the line matches the "name" pattern
            name_match = name_pattern.search(line)
            if name_match:
                current_name = name_match.group(1)  # Extract the name
                print(f"Found Name: {current_name}")  # Debug: Print the found name

            # Detect if we're inside the "card_sets" section
            if '"card_sets": [' in line:
                inside_card_sets = True
                rarity_count = {}  # Reset the rarity count dictionary for a new card
                print("Entering card_sets section.")  # Debug: Enter card_sets section

            # Capture rarity while inside "card_sets"
            if inside_card_sets:
                set_rarity_match = set_rarity_pattern.search(line)

                # If we find a set rarity, check if it's in the allowed list and then increment the count
                if set_rarity_match:
                    set_rarity = set_rarity_match.group(1)
                    print(f"Found Set Rarity: {set_rarity}")  # Debug: Found set rarity

                    # Only count rarities in the allowed list
                    if set_rarity in allowed_rarities:
                        if set_rarity in rarity_count:
                            rarity_count[set_rarity] += 1
                        else:
                            rarity_count[set_rarity] = 1
                        print(f"Rarity Count Updated: {rarity_count}")  # Debug: Updated rarity count
                    else:
                        print(f"Skipping Rarity: {set_rarity} (Not in allowed list)")  # Debug: Skipping rarity

            # End of "card_sets" section
            if inside_card_sets and ']' in line:
                inside_card_sets = False
                print("Exiting card_sets section.")  # Debug: Exit card_sets section

                # If we have all required fields, calculate the averaged rarity chance
                if current_id and current_name and rarity_count:
                    total_rarities = sum(rarity_count.values())

                    # Calculate the weighted average rarity chance
                    weighted_sum = sum(rarity_weights[rarity] * count for rarity, count in rarity_count.items())
                    averaged_rarity_chance = weighted_sum / total_rarities if total_rarities > 0 else 0

                    # Find the closest rarity based on the averaged rarity chance
                    closest_rarity_name = closest_rarity(averaged_rarity_chance)

                    # Create the output string for rarities
                    rarity_string = ",".join([f"{rarity}={count}" for rarity, count in rarity_count.items()])

                    # Add to output with the averaged rarity chance and closest rarity
                    output_lines.append(f"{current_id}|{current_name}|{rarity_string}|{averaged_rarity_chance:.2f}%|{closest_rarity_name}")
                    print(f"Adding to output: {current_id}|{current_name}|{rarity_string}|{averaged_rarity_chance:.2f}%|{closest_rarity_name}")  # Debug: Output
                else:
                    print(f"Missing data - ID: {current_id}, Name: {current_name}, Sets: {rarity_count}")  # Debug: Missing data

                # Reset for next card
                current_id = None
                current_name = None
                rarity_count = {}

        # Write the output lines to the output file, each on a new line
        outfile.write("\n".join(output_lines))

    # Print the results to the console
    print(f"Processed {len(output_lines)} cards with sets.")
    print(f"Filtered data has been written to {output_filename}")

except FileNotFoundError:
    print(f"The file '{input_filename}' was not found. Please ensure the file is in the same directory as the script.")
except UnicodeDecodeError:
    print(f"Error: Unable to decode the file '{input_filename}'. Try using a different encoding.")