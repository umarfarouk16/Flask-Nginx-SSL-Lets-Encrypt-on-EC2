#!/bin/bash

set -e

VENV_DIR=".venv"

echo "Setting up Python virtual environment..."

# Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "Created virtual environment at ./$VENV_DIR"
else
    echo "Virtual environment already exists at ./$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Upgrade pip
pip install --upgrade pip

# Install dependencies
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo "Dependencies installed from requirements.txt"
else
    echo "Warning: requirements.txt not found, skipping dependency install"
fi

echo "Environment ready."

# Run the application
gunicorn -w 4 -b 0.0.0.0:8000 app:app &

# Run nginx
# nginx -g "daemon off;"
