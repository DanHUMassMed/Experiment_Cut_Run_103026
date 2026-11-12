#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_DIR="${SCRIPT_DIR}/../../Cut_And_Run_Analysis"

if [[ -f "${PIPELINE_DIR}/manage.sh" ]]; then
    ANALYSIS_DIR="${SCRIPT_DIR}" "${PIPELINE_DIR}/manage.sh" run
else
    echo "Error: Could not locate Cut_And_Run_Analysis/manage.sh"
    exit 1
fi