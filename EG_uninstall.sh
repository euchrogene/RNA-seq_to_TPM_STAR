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

echo "--- EuchroGene Tool Removal Process ---"

echo "[1/3] Removing Docker image: $DOCKER_IMAGE"
if [[ "$(sudo docker images -q "$DOCKER_IMAGE" 2> /dev/null)" != "" ]]; then
    sudo docker rmi -f "$DOCKER_IMAGE"
    echo "  >> Done."
else
    echo "  >> Image not found, skipping."
fi

echo "[2/3] Deleting wrapper from system path: $TARGET_BIN/$EXE_FILE"
if [ -f "$TARGET_BIN/$EXE_FILE" ]; then
    sudo rm "$TARGET_BIN/$EXE_FILE"
    echo "  >> Done."
else
    echo "  >> Wrapper not found."
fi

echo "[3/3] Updating registered tool list..."
if [ -f "$DATA_FILE" ]; then
    # 해당 툴 항목 삭제
    sudo sed -i "/$EXE_FILE/d" "$DATA_FILE"
    
    # 만약 파일이 비어있다면 전체 환경 정리
    if [ ! -s "$DATA_FILE" ]; then
        echo "  >> No tools remaining. Removing EG_tools viewer and database."
        sudo rm "$DATA_FILE"
        sudo rm "$VIEWER_SCRIPT"
    else
        echo "  >> Tool removed from list. Other tools still available."
    fi
fi

echo "---------------------------------------"
echo "Uninstallation of $EXE_FILE complete."
echo "Note: This script (eg_uninstall.sh) was not copied to your system path."
