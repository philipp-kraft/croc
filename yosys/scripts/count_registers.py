from collections import Counter
from pathlib import Path
import argparse
import csv

REPORT_DIR = Path(__file__).resolve().parent
DEFAULT_INPUT = REPORT_DIR / "../reports/core_registers.rpt"
DEFAULT_OUTPUT = REPORT_DIR / "../reports/core_registers_by_block.csv"

BLOCK_MAP = [
    ("register_file_i", "RF"),
    ("rf_lower_bank_i", "RF"),
    ("rf_upper_bank_i", "RF"),
    ("rf_reg_", "RF"),

    ("if_stage_i", "IF"),
    ("id_stage_i", "ID"),
    ("ex_block_i", "EX"),
    ("load_store_unit_i", "LSU"),
    ("cs_registers_i", "CSR"),
]

def is_register(path):
    return (
        path.endswith("_reg")
        or "__reg" in path
        or "_reg_" in path
    )

def classify(path):
    for key, block in BLOCK_MAP:
        if key in path:
            return block
    return "Other"

def count_registers(input_path):
    counts = Counter()
    other_examples = []
    skipped = 0

    with input_path.open() as f:
        for line in f:
            path = line.strip()

            if not path or path.startswith("#"):
                continue

            if not is_register(path):
                skipped += 1
                continue

            block = classify(path)
            counts[block] += 1

            if block == "Other" and len(other_examples) < 20:
                other_examples.append(path)

    return counts, skipped, other_examples


def write_counts(output_path, counts):
    with output_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["block", "registers"])
        for block, count in sorted(counts.items()):
            writer.writerow([block, count])
        writer.writerow(["Total", sum(counts.values())])


def parse_args():
    parser = argparse.ArgumentParser(
        description="Count Yosys-selected DFF/register cells by core block."
    )
    parser.add_argument(
        "-i",
        "--input",
        type=Path,
        default=DEFAULT_INPUT,
        help=f"register report to parse (default: {DEFAULT_INPUT})",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"CSV file to write (default: {DEFAULT_OUTPUT})",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    if not args.input.exists():
        raise SystemExit(f"Input report not found: {args.input}")

    counts, skipped, other_examples = count_registers(args.input)
    write_counts(args.output, counts)

    print(f"Wrote {args.output}")
    print(f"Total registers: {sum(counts.values())}")
    print(f"Skipped non-register lines: {skipped}")
    print(counts)

    if other_examples:
        print("\nOther examples:")
        for path in other_examples:
            print(path)


if __name__ == "__main__":
    main()
