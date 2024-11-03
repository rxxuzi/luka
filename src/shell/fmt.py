#!/usr/bin/env python3
import sys
import argparse
import json
import csv

try:
    import yaml
except ImportError:
    yaml = None

def parse_key_value(input_lines):
    data = {}
    for line in input_lines:
        line = line.strip()
        if not line or '=' not in line:
            continue
        key, value = line.split('=', 1)
        keys = key.split('.')
        d = data
        for k in keys[:-1]:
            if k not in d:
                d[k] = {}
            d = d[k]
        # Remove surrounding quotes if present
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        # Convert numeric values to integers or floats if possible
        if value.isdigit():
            value = int(value)
        else:
            try:
                value = float(value)
            except ValueError:
                pass
        d[keys[-1]] = value
    return data

def main():
    parser = argparse.ArgumentParser(description="Format system information to JSON, YAML, or CSV.")
    parser.add_argument('-f', '--format', choices=['json', 'yaml', 'csv'], default='json', help='Output format: json, yaml, or csv (default: json)')
    args = parser.parse_args()

    input_lines = sys.stdin.readlines()
    data = parse_key_value(input_lines)

    if args.format == 'json':
        output = json.dumps(data, indent=4)
    elif args.format == 'yaml':
        if yaml is None:
            sys.stderr.write("Error: PyYAML is not installed. Install it using 'pip install pyyaml'\n")
            sys.exit(1)
        output = yaml.dump(data, sort_keys=False)
    elif args.format == 'csv':
        # Flatten the data for CSV output
        flat_data = []
        def flatten(d, parent_key=''):
            for k, v in d.items():
                new_key = f"{parent_key}.{k}" if parent_key else k
                if isinstance(v, dict):
                    flatten(v, new_key)
                else:
                    flat_data.append((new_key, v))
        flatten(data)

        # Output CSV to stdout
        writer = csv.writer(sys.stdout)
        writer.writerow(['Key', 'Value'])
        writer.writerows(flat_data)
        sys.exit(0)
    else:
        sys.stderr.write(f"Unsupported format: {args.format}\n")
        sys.exit(1)

    print(output)

if __name__ == "__main__":
    main()
