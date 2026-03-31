# Copyright 2026 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your
# agreement with Google

import functions_framework
import os
from google.cloud import bigquery
from datetime import datetime, timezone

# Configuration - could be moved to environment variables
PROJECT_ID = os.environ.get('PROJECT_ID', 'docomo-udk-mlops-2025')
DATASET_ID = os.environ.get('DATASET_ID', 'feedbacks')
TABLE_NAME = os.environ.get('TABLE_NAME', 'monthly_feedback')

@functions_framework.http
def handle_feedback(request):
    """
    HTTP Cloud Function to collect user feedback and insert into BigQuery.
    
    Expected JSON payload:
    {
        "series_id": "string",
        "timestamp": "YYYY-MM-DD HH:MM:SS",
        "label_type": "FP" | "FN",
        "reason_category": "EVENT" | "MAINTENANCE" | "NOISE"
    }
    """
    request_json = request.get_json(silent=True)
    
    if not request_json:
        return 'Invalid request: JSON body required', 400

    required_fields = ['series_id', 'timestamp', 'label_type', 'reason_category']
    if not all(field in request_json for field in required_fields):
        return f'Missing required fields: {required_fields}', 400

    # Validate inputs
    label_type = request_json['label_type']
    if label_type not in ['FP', 'FN']:
        return "Invalid label_type. Must be 'FP' or 'FN'.", 400
        
    reason_category = request_json['reason_category']
    if reason_category not in ['EVENT', 'MAINTENANCE', 'NOISE']:
        return "Invalid reason_category. Must be 'EVENT', 'MAINTENANCE', or 'NOISE'.", 400

    try:
        # Prepare row for insertion
        row = {
            "series_id": request_json['series_id'],
            "timestamp": request_json['timestamp'], # Assumes correct format, BQ validates
            "label_type": label_type,
            "reason_category": reason_category,
            "feedback_at": datetime.now(timezone.utc).isoformat()
        }

        client = bigquery.Client(project=PROJECT_ID)
        table_id = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_NAME}"
        
        errors = client.insert_rows_json(table_id, [row])
        
        if errors == []:
            print(f"Successfully inserted feedback for {row['series_id']} at {row['timestamp']}")
            return {"status": "success", "message": "Feedback recorded successfully"}, 200
        else:
            print(f"Encountered errors while inserting rows: {errors}")
            return {"status": "error", "errors": str(errors)}, 500

    except Exception as e:
        print(f"Error processing feedback: {e}")
        return {"status": "error", "message": str(e)}, 500
