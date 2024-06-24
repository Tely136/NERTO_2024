import os
import shutil

# Define the root directory and target directory
root_dir = '/mnt/disks/data-disk/downloads/TEMPO_NO2_202403-001'
target_dir = '/mnt/disks/data-disk/downloads/temp_folder'

# Create the target directory if it doesn't exist
os.makedirs(target_dir, exist_ok=True)

# Walk through the directory structure
for root, dirs, files in os.walk(root_dir):
    for file in files:
        # Construct full file path
        file_path = os.path.join(root, file)
        target_file_path = os.path.join(target_dir, file)
        
        # Move file to the target directory, overwriting if it already exists
        if os.path.exists(target_file_path):
            os.remove(target_file_path)
        shutil.move(file_path, target_dir)

print(f"All files have been moved to {target_dir}")
