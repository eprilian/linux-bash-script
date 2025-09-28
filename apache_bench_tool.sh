#!/bin/bash

# ===============================================
# Interactive ApacheBench Load Testing Script
# ===============================================

echo "=================================================="
echo " Welcome to the Interactive Load Tester!"
echo "=================================================="
echo "Please provide the details for your load test."
echo ""

# --- PROMPT FOR INPUT ---

# 1. Get the target URL
read -p "Enter the target URL (e.g., https://example.com/): " TARGET_URL
if [[ -z "$TARGET_URL" ]]; then
    TARGET_URL="https://example.com/"
    echo "Using default URL: $TARGET_URL"
fi
echo ""

# 2. Get the total number of requests
read -p "Enter the total number of requests (e.g., 100): " TOTAL_REQUESTS
if [[ -z "$TOTAL_REQUESTS" ]]; then
    TOTAL_REQUESTS=100
    echo "Using default total requests: $TOTAL_REQUESTS"
fi
echo ""

# 3. Get the concurrency level
read -p "Enter the concurrency level (e.g., 10): " CONCURRENCY
if [[ -z "$CONCURRENCY" ]]; then
    CONCURRENCY=10
    echo "Using default concurrency: $CONCURRENCY"
fi
echo ""

# 4. Ask about form data (POST request)
read -p "Do you want to send form data? (y/n): " send_post_data
POST_ARGS=""
if [[ "$send_post_data" =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Enter the path to the data file (e.g., ./form_data.txt): " DATA_FILE
    if [[ -z "$DATA_FILE" ]]; then
        echo "No data file specified. Aborting POST data submission."
    elif [ -f "$DATA_FILE" ]; then
        read -p "Enter the Content-Type (e.g., application/x-www-form-urlencoded): " CONTENT_TYPE
        if [[ -z "$CONTENT_TYPE" ]]; then
            CONTENT_TYPE="application/x-www-form-urlencoded"
            echo "Using default Content-Type: $CONTENT_TYPE"
        fi
        POST_ARGS="-p \"$DATA_FILE\" -T \"$CONTENT_TYPE\""
    else
        echo "Error: Data file '$DATA_FILE' not found. Skipping POST data."
    fi
fi

# --- EXECUTION ---

OUTPUT_FILE="ab_results_$(date +%Y%m%d_%H%M%S).txt"
echo ""
echo "=================================================="
echo " Test Parameters:"
echo "=================================================="
echo "Target URL:       $TARGET_URL"
echo "Total Requests:   $TOTAL_REQUESTS"
echo "Concurrency:      $CONCURRENCY"
echo "Using POST data:  ${POST_ARGS:+"Yes"} ${POST_ARGS:-"No"}"
echo "Saving results to: $OUTPUT_FILE"
echo "--------------------------------------------------"
echo ""
echo "Running the test... Please wait."
echo ""

# Run the ApacheBench command
ab -n "$TOTAL_REQUESTS" -c "$CONCURRENCY" -k $POST_ARGS "$TARGET_URL" > "$OUTPUT_FILE" 2>&1

# --- POST-EXECUTION SUMMARY ---

if [ $? -eq 0 ]; then
    echo "Load test completed successfully."
    echo "Summary of key metrics:"
    REQUESTS_PER_SECOND=$(grep "Requests per second:" "$OUTPUT_FILE" | awk '{print $4}')
    TIME_PER_REQUEST=$(grep "Time per request:" "$OUTPUT_FILE" | head -n 1 | awk '{print $4 $5}')
    TRANSFER_RATE=$(grep "Transfer rate:" "$OUTPUT_FILE" | awk '{print $3 $4}')

    echo "  Requests per second: $REQUESTS_PER_SECOND"
    echo "  Average Time per Request: $TIME_PER_REQUEST (across all concurrent requests)"
    echo "  Transfer Rate: $TRANSFER_RATE"
    echo ""
    echo "Full report saved to: $OUTPUT_FILE"
else
    echo "Error: ApacheBench failed to execute. Check the output file for details."
fi
