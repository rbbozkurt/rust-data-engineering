#!/bin/bash

# Stop execution if any command fails
set -e

# Rust version parameter (default to 1.74.0 if not specified)
RUST_VERSION="${1:-1.74.0}"

# Python version parameter (default to 3.10 if not specified)
PYTHON_VERSION="${2:-3.10}"

# Function to check if a command is available
command_exists() {
    command -v "$1" &>/dev/null
}

# Install Rust and set the specified version, if not already installed or set
install_rust() {
    echo "Checking Rust installation..."
    if ! command_exists rustup; then
        echo "Rustup not found. Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
    else
        echo "Rust is already installed."
    fi

    echo "Setting Rust to version $RUST_VERSION..."
    rustup install "$RUST_VERSION" || true  # Proceed if the version is already installed
    rustup default "$RUST_VERSION"
}

# Install Clippy and Rustfmt
install_rust_tools() {
    echo "Installing Rust tools (clippy, rustfmt)..."
    rustup component add clippy || true  # Proceed if clippy is already installed
    rustup component add rustfmt || true  # Proceed if rustfmt is already installed
}

# Install Python 3 if not already installed
install_python3() {
    echo "Checking for Python3..."
    if ! command_exists python3; then
        echo "Python3 not found. Attempting to install..."
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y python3
        elif command_exists yum; then
            sudo yum install -y python3
        elif command_exists brew; then
            brew install python3
        else
            echo "Package manager not found. You may need to install Python3 manually."
            exit 1
        fi
    else
        echo "Python3 is already installed."
    fi
}

# Ensure pip for Python3 is installed
ensure_pip() {
    echo "Checking for pip3..."
    if ! command_exists pip3; then
        echo "pip3 not found. Attempting to install..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py --user
        rm get-pip.py
    else
        echo "pip3 is already installed."
    fi
}

# Install Pipenv
install_pipenv() {
    echo "Checking for Pipenv..."
    if ! command_exists pipenv; then
        echo "Pipenv not found. Installing Pipenv..."
        pip3 install --user pipenv
    else
        echo "Pipenv is already installed."
    fi
    if [ ! -f Pipfile ]; then
        echo "Creating Pipfile with Python version $PYTHON_VERSION..."
        pipenv --python "$PYTHON_VERSION"
    fi
}

# Install pre-commit using pipenv
install_pre_commit() {
    echo "Installing pre-commit..."
    pipenv install pre-commit
}

# Setup pre-commit hooks from .pre-commit-config.yaml if it exists
setup_pre_commit_hooks() {
    if [ -f .pre-commit-config.yaml ]; then
        echo "Setting up pre-commit hooks..."
        pipenv run pre-commit install
    else
        echo "No .pre-commit-config.yaml found. Skipping pre-commit hook setup."
    fi
}

# Main setup function
main_setup() {
    install_rust
    install_rust_tools
    install_python3
    ensure_pip
    install_pipenv
    install_pre_commit
    setup_pre_commit_hooks
    echo "Setup completed successfully."
}

# Run the main setup function
main_setup