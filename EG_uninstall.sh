#!/bin/bash

# Configuration
TARGET_BIN="/usr/bin"
DATA_FILE="/usr/share/euchrogene_tools.txt"
VIEWER_SCRIPT="$TARGET_BIN/EG_tools"

usage() {
    echo "Usage: sudo ./eg_uninstall.sh -t <TOOL_NAME> -i <DOCKER_IMAGE>"
    echo "Example: sudo ./eg_uninstall.sh -t RNA_seq_to_TPM_Bowtie2_v.1.0 -i managene7/rna-seq_to_tpm_deseq2:v.1.0"
    exit 1
}

while getopts "t:i:" opt; do
    case $opt in
        t) EXE_FILE="$OPTARG" ;;
        i) DOCKER_IMAGE="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "$EXE_FILE" ] || [ -z "$DOCKER_IMAGE" ]; then
    usage
fi

echo "--- EuchroGene Universal Uninstaller ---"

echo "[1/4] Checking Docker image: $DOCKER_IMAGE"
if [[ "$(sudo docker images -q "$DOCKER_IMAGE" 2> /dev/null)" != "" ]]; then
    sudo docker rmi -f "$DOCKER_IMAGE"
    echo "  >> Docker image deleted."
else
    echo "  >> Image not found, skipping."
fi

echo "[2/4] Removing wrapper: $TARGET_BIN/$EXE_FILE"
if [ -f "$TARGET_BIN/$EXE_FILE" ]; then
    sudo rm "$TARGET_BIN/$EXE_FILE"
    echo "  >> Wrapper removed."
else
    echo "  >> Wrapper not found."
fi

echo "[3/4] Updating registry: $DATA_FILE"
if [ -f "$DATA_FILE" ]; then
    # 정확한 매칭을 위해 sed 사용
    sudo sed -i "/$EXE_FILE/d" "$DATA_FILE"
    echo "  >> Registry updated."
fi

echo "[4/4] Checking for remaining tools..."
if [ -f "$DATA_FILE" ]; then
    if [ ! -s "$DATA_FILE" ]; then
        echo "  >> No more tools left. Cleaning up global scripts."
        sudo rm "$DATA_FILE"
        sudo rm "$VIEWER_SCRIPT"
    else
        echo "  >> Other tools remain. Keeping $VIEWER_SCRIPT."
        echo "--- Remaining Tools ---"
        cat "$DATA_FILE"
    fi
fi

echo "---------------------------------------"
echo "Uninstallation of $EXE_FILE complete."
