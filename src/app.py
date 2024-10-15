#!/usr/bin/env python3

import os
import sys
import json
import platform
import urllib.request
import tarfile
import zipfile
import shutil
import argparse
import logging

# Configure logging
logging.basicConfig(
    filename=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'app.log'),
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Constants
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BIN_DIR = os.path.abspath(os.path.join(BASE_DIR, '../pkg'))
DB_FILE = os.path.join(BASE_DIR, 'database/app.db.json')

def setup_directories():
    """
    Ensure that the BIN_DIR exists.
    """
    if not os.path.exists(BIN_DIR):
        os.makedirs(BIN_DIR)
        logging.info(f"Created BIN_DIR at {BIN_DIR}")
    else:
        logging.info(f"BIN_DIR already exists at {BIN_DIR}")

def load_app_database():
    """
    Load the application database from the JSON file.
    """
    if not os.path.exists(DB_FILE):
        logging.error(f"Database file not found at {DB_FILE}")
        print(f"Error: Database file not found at {DB_FILE}")
        sys.exit(1)
    
    with open(DB_FILE, 'r') as f:
        try:
            apps = json.load(f)
            logging.info("Loaded application database successfully.")
            return apps
        except json.JSONDecodeError as e:
            logging.error(f"JSON decode error: {e}")
            print("Error: Failed to parse the application database.")
            sys.exit(1)

def list_apps(apps):
    """
    List all available applications.
    """
    print("Available apps:")
    for app in sorted(apps.keys()):
        print(f"  {app}")

def get_architecture():
    """
    Determine the system architecture.
    """
    arch = platform.machine()
    arch_mapping = {
        'x86_64': 'amd64',
        'i686': 'i686',
        'i386': 'i686',
        'arm64': 'arm64',
        'aarch64': 'arm64'
    }
    normalized_arch = arch_mapping.get(arch, arch)
    logging.info(f"Detected architecture: {arch} mapped to {normalized_arch}")
    return normalized_arch

def download_file(url, dest_path):
    """
    Download a file from a URL to a destination path with a progress indicator.
    """
    try:
        with urllib.request.urlopen(url) as response, open(dest_path, 'wb') as out_file:
            total_length = response.getheader('content-length')
            if total_length is None:
                shutil.copyfileobj(response, out_file)
            else:
                total_length = int(total_length)
                downloaded = 0
                chunk_size = 8192
                while True:
                    chunk = response.read(chunk_size)
                    if not chunk:
                        break
                    out_file.write(chunk)
                    downloaded += len(chunk)
                    done = int(50 * downloaded / total_length)
                    sys.stdout.write('\r[{}{}] {:.2f}%'.format(
                        '=' * done, ' ' * (50 - done), (downloaded / total_length) * 100))
                    sys.stdout.flush()
        sys.stdout.write('\n')
        logging.info(f"Downloaded file from {url} to {dest_path}")
    except Exception as e:
        logging.error(f"Failed to download {url}: {e}")
        print(f"Error: Failed to download {url}. {e}")
        sys.exit(1)

def extract_archive(file_path, extract_to):
    """
    Extract a tar or zip archive to a specified directory.
    """
    try:
        if tarfile.is_tarfile(file_path):
            with tarfile.open(file_path, 'r:*') as tar:
                tar.extractall(path=extract_to)
            logging.info(f"Extracted tar archive {file_path} to {extract_to}")
        elif zipfile.is_zipfile(file_path):
            with zipfile.ZipFile(file_path, 'r') as zip_ref:
                zip_ref.extractall(path=extract_to)
            logging.info(f"Extracted zip archive {file_path} to {extract_to}")
        else:
            logging.warning(f"Unknown archive format for {file_path}")
            print(f"Warning: Unknown archive format for {file_path}. Skipping extraction.")
    except Exception as e:
        logging.error(f"Failed to extract {file_path}: {e}")
        print(f"Error: Failed to extract {file_path}. {e}")
        sys.exit(1)

def move_executables(extract_dir, bin_dir):
    """
    Move executable files from the extraction directory to the BIN_DIR.
    """
    try:
        for root, dirs, files in os.walk(extract_dir):
            for file in files:
                file_path = os.path.join(root, file)
                if os.access(file_path, os.X_OK) and not os.path.isdir(file_path):
                    shutil.move(file_path, bin_dir)
                    logging.info(f"Moved executable {file} to {bin_dir}")
                    print(f"Installed executable: {file}")
        # Remove any empty directories left after moving executables
        shutil.rmtree(extract_dir, ignore_errors=True)
    except Exception as e:
        logging.error(f"Failed to move executables from {extract_dir} to {bin_dir}: {e}")
        print(f"Error: Failed to move executables. {e}")
        sys.exit(1)

def install_app(app_name, apps, arch, bin_dir):
    """
    Install a single application.
    """
    app_info = apps.get(app_name)
    if not app_info:
        logging.error(f"App '{app_name}' not found in the database.")
        print(f"Error: '{app_name}' is not available.")
        return
    
    url = app_info.get(arch)
    if not url:
        logging.error(f"App '{app_name}' is not available for architecture '{arch}'.")
        print(f"Error: '{app_name}' is not available for your architecture '{arch}'.")
        return
    
    file_name = url.split('/')[-1]
    file_path = os.path.join(bin_dir, file_name)
    
    if os.path.exists(file_path):
        print(f"{file_name} already exists. Removing the old file.")
        os.remove(file_path)
        logging.info(f"Removed existing file {file_path}")
    
    print(f"Downloading {app_name} from {url}...")
    download_file(url, file_path)
    
    print(f"Extracting {file_name}...")
    extract_archive(file_path, bin_dir)
    
    print(f"Moving executables to {bin_dir}...")
    extract_dir = os.path.splitext(file_path)[0]  # Remove extension
    move_executables(extract_dir, bin_dir)
    
    # Remove the downloaded archive
    os.remove(file_path)
    logging.info(f"Removed archive file {file_path}")
    
    print(f"{app_name} has been installed to {bin_dir}.")

def remove_app(app_name, bin_dir):
    """
    Remove a single application.
    """
    app_path = os.path.join(bin_dir, app_name)
    if os.path.exists(app_path):
        try:
            if os.path.isdir(app_path):
                shutil.rmtree(app_path)
                logging.info(f"Removed directory {app_path}")
            else:
                os.remove(app_path)
                logging.info(f"Removed file {app_path}")
            print(f"{app_name} has been removed from {bin_dir}.")
        except Exception as e:
            logging.error(f"Failed to remove {app_path}: {e}")
            print(f"Error: Failed to remove {app_name}. {e}")
    else:
        print(f"Error: '{app_name}' is not installed.")
        logging.warning(f"Attempted to remove non-existent app '{app_name}'")

def check_app_exists(app_name, apps):
    """
    Check if an app exists in the database.
    """
    if app_name in apps:
        print(f"'{app_name}' exists in the application database.")
    else:
        print(f"'{app_name}' does not exist in the application database.")

def show_help():
    """
    Display help message.
    """
    help_message = """
Luka App Manager - Install and manage applications without administrative privileges.

Usage:
  luka app <command> [<args>]

Commands:
  install <app_name>       Install the specified app
  remove <app_name>        Remove the specified app
  list                     List all available apps
  exists <app_name>        Check if an app exists
  help                     Show this help message
"""
    print(help_message)

def parse_arguments():
    """
    Parse command-line arguments using argparse.
    """
    # Adjust sys.argv if 'app' is the second argument
    if len(sys.argv) > 1 and sys.argv[1] == 'app':
        sys.argv = [sys.argv[0]] + sys.argv[2:]
    
    parser = argparse.ArgumentParser(
        description="Luka App Manager - Install and manage applications without administrative privileges.",
        add_help=False
    )
    parser.add_argument('command', nargs='?', help='Sub-command to run')
    parser.add_argument('app_name', nargs='?', help='Name of the app')
    parser.add_argument('--help', '-h', action='store_true', help='Show help message')
    
    args = parser.parse_args()
    return args

def main():
    """
    Main function to execute the install/remove/list commands.
    """
    setup_directories()
    args = parse_arguments()
    apps = load_app_database()
    arch = get_architecture()
    
    if args.help or args.command == 'help':
        show_help()
        sys.exit(0)
    
    if args.command == 'list':
        list_apps(apps)
    elif args.command == 'install' and args.app_name:
        install_app(args.app_name, apps, arch, BIN_DIR)
    elif args.command == 'remove' and args.app_name:
        remove_app(args.app_name, BIN_DIR)
    elif args.command == 'exists' and args.app_name:
        check_app_exists(args.app_name, apps)
    else:
        show_help()
        sys.exit(1)

if __name__ == '__main__':
    main()
