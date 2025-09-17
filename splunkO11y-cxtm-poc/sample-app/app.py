#!/usr/bin/env python3
"""
Simple Flask Application - Before any instrumentation
This is our baseline to observe changes
"""

from flask import Flask, jsonify, request
import time
import random
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

def simulate_database_call():
    """Simulate a database operation"""
    time.sleep(random.uniform(0.01, 0.05))
    return {"data": f"record_{random.randint(1000, 9999)}"}

@app.route('/')
def home():
    """Main endpoint"""
    logger.info("Home endpoint accessed")
    db_data = simulate_database_call()

    return jsonify({
        "service": "sample-app",
        "status": "running",
        "version": "1.0.0",
        "data": db_data,
        "message": "Simple Flask app before instrumentation"
    })

@app.route('/healthz')
def health():
    """Health check"""
    return jsonify({"status": "healthy"})

@app.route('/api/users')
def get_users():
    """Users API"""
    logger.info("Getting users")
    db_data = simulate_database_call()

    users = [
        {"id": 1, "name": "John Doe"},
        {"id": 2, "name": "Jane Smith"}
    ]

    return jsonify({
        "users": users,
        "metadata": db_data
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)