#!/bin/bash

ROOT_OUTPUT_DIR="/tmp"
OUTPUT_DIR_NAME="pod_logs_$(kubectl config current-context)_$(date +%s)"
OUTPUT_DIR="${ROOT_OUTPUT_DIR}/${OUTPUT_DIR_NAME}"
EXTENSION="log"
echo "Using output dir $OUTPUT_DIR"
mkdir "$OUTPUT_DIR"

# Get all pod logs and describe
kubectl get po -A --no-headers | while read -r line; do
    NAMESPACE=$(echo "$line" | awk '{print $1}')
    POD_NAME=$(echo "$line" | awk '{print $2}')
    FILENAME="${OUTPUT_DIR}/${NAMESPACE}.${POD_NAME}.describe"
    kubectl describe pod -n "$NAMESPACE" "$POD_NAME" > "$FILENAME"
    for CONTAINER in $(kubectl get po -n "$NAMESPACE" "$POD_NAME" -o jsonpath="{.spec.containers[*].name}"); do
        FILENAME_PREFIX="${OUTPUT_DIR}/${NAMESPACE}.${POD_NAME}.${CONTAINER}"
        FILENAME="${FILENAME_PREFIX}.current.${EXTENSION}"
        echo "$FILENAME"
        kubectl logs -n "$NAMESPACE" "$POD_NAME" "$CONTAINER" > "$FILENAME"
        FILENAME="${FILENAME_PREFIX}.previous.${EXTENSION}"
        echo "$FILENAME"
        kubectl logs -p -n "$NAMESPACE" "$POD_NAME" "$CONTAINER" > "$FILENAME" 2> /dev/null
    done
done

# Dump all events
FILENAME="${OUTPUT_DIR}/events.log"
kubectl get events -A > "$FILENAME"

CWD=$(pwd)
cd $ROOT_OUTPUT_DIR || exit 1

TARBALL_FILE_NAME="${OUTPUT_DIR_NAME}.tar.gz"
tar -czvf "./${TARBALL_FILE_NAME}" "./${OUTPUT_DIR_NAME}"
mv "./${TARBALL_FILE_NAME}" "$OUTPUT_DIR"

echo
echo "Files located at $OUTPUT_DIR"
echo "Tarball located at ${OUTPUT_DIR}/${TARBALL_FILE_NAME}"
echo
echo "Search for errors:"
echo "  $ grep -Ei \"fail|err\" ${OUTPUT_DIR}/*.log"

cd "$CWD" || exit 1
