#!/bin/bash

# Configuration
REPO_URL="https://github.com/euchrogene/RNA-seq_to_TPM_STAR.git"
REPO_DIR="RNA-seq_to_TPM_STAR"
EXE_FILE="RNA-seq_to_TPM_STAR"
PIPELINE_ENTRY="$EXE_FILE => A pipeline to process RNA-seqs to get TPM, FPKM, and Count data using AdapterRemoval=>STAR=>RSEM"

TARGET_BIN="/usr/bin"
DATA_FILE="/usr/share/euchrogene_tools.txt"
VIEWER_SCRIPT="$TARGET_BIN/EG_tools"

echo "Step 1: Downloading repository..."
# Clean up any previous failed attempts first
[ -d "$REPO_DIR" ] && rm -rf "$REPO_DIR"
git clone "$REPO_URL"

echo "Step 2 & 3: Installing executables..."
cd "$REPO_DIR" || exit
chmod +x *
sudo cp * "$TARGET_BIN/"

echo "Step 4: Removing the downloaded repository folder..."
cd ..
rm -rf "$REPO_DIR"

echo "Step 5: Updating the pipeline text database..."
sudo touch "$DATA_FILE"

# Add entry if it doesn't exist
if ! grep -q "$EXE_FILE" "$DATA_FILE"; then
    echo "$PIPELINE_ENTRY" | sudo tee -a "$DATA_FILE" > /dev/null
fi

# Sort the text file alphabetically
sudo sort -o "$DATA_FILE" "$DATA_FILE"

echo "Step 6: Ensuring the viewer script exists..."
sudo bash -c "cat <<EOF > $VIEWER_SCRIPT
#!/bin/bash
echo ''
echo '--- Registered EuchroGene Tools ---'
cat $DATA_FILE
echo '--------------------------------------'
EOF"

sudo chmod +x "$VIEWER_SCRIPT"

echo ""
echo "Success! Installation complete and temporary files removed."
echo ""
echo "If you want to delete the pipeline list not used anymore, open the file in /usr/share/euchrogene_tools.txt and revise it."
