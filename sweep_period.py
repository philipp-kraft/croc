#!/usr/bin/env python3

import subprocess
import shutil
import os
import re

SDC_PATH = "openroad/src/constraints.sdc"
REPORT_PATH = "openroad/reports/05_core.final.rpt"
RESULTS_DIR = "results/sweep"
FLOW_CMD = "./croc.sh all"

PERIODS = [10.0, 5.8, 5.5]

def modify_sdc(sdc_path, period):
    with open(sdc_path, "r") as f:
        content = f.read()

    content = re.sub(
        r"^set TCK_SYS\s+.*$",
        f"set TCK_SYS {period:.1f}",
        content,
        flags=re.MULTILINE,
    )

    with open(sdc_path, "w") as f:
        f.write(content)


def run_flow():
    result = subprocess.run(
        FLOW_CMD,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return result.returncode, result.stdout

def write_summary_row(summary_file, row):
    summary_file.write(",".join(str(v) for v in row) + "\n")
    summary_file.flush()
    os.fsync(summary_file.fileno())

def make_unique_dir(base_dir):
    idx = 1
    while True:
        candidate = f"{base_dir}_{idx:02d}"
        if not os.path.exists(candidate):
            os.makedirs(candidate)
            return candidate
        idx += 1

def main():
    # Read original SDC to restore later
    with open(SDC_PATH, "r") as f:
        original_sdc = f.read()

    results_dir = make_unique_dir(RESULTS_DIR)

    header_fields = [
        "period",
        "frequency",
        "wns",
        "tns",
        "slack",
        "area_top",
        "area_i_core",
        "area_cs_registers",
        "area_ex_block",
        "area_id_stage",
        "area_if_stage",
        "area_lsu",
        "area_register_file",
        "status",
    ]

    header = ",".join(header_fields)

    summary_path = os.path.join(results_dir, "summary.csv")

    try:
        with open(summary_path, "w") as summary_file:
            summary_file.write(header + "\n")
            summary_file.flush()
            os.fsync(summary_file.fileno())

            for period in PERIODS:
                freq_mhz = 1000.0 / period
                run_name = f"{period:.1f}ns_{freq_mhz:.0f}MHz"
                run_dir = os.path.join(results_dir, run_name)
                os.makedirs(run_dir, exist_ok=True)

                print(f"\n{'='*60}")
                print(f"Running: TCK_SYS = {period:.1f} ns ({freq_mhz:.0f} MHz)")
                print(f"{'='*60}")

                modify_sdc(SDC_PATH, period)

                returncode, log = run_flow()

                with open(os.path.join(run_dir, "build.log"), "w") as f:
                    f.write(log)

                if os.path.exists(REPORT_PATH):
                    shutil.copy2(REPORT_PATH, os.path.join(run_dir, "05_core.final.rpt"))

                    with open(REPORT_PATH, "r") as f:
                        report = f.read()

                    wns = extract_metric(report, r"wns max\s+([-\d.]+)")
                    tns = extract_metric(report, r"tns max\s+([-\d.]+)")
                    slack = extract_metric(report, r"worst slack max\s+([-\d.]+)")
                    area_top = extract_metric(report, r"^<top>\s+([\d.]+)", re.MULTILINE)

                    area_core = extract_metric(report, r"^\s+i_core\s+([\d.]+)", re.MULTILINE)
                    area_csr = extract_metric(report, r"^\s+cs_registers_i\s+([\d.]+)", re.MULTILINE)
                    area_ex = extract_metric(report, r"^\s+ex_block_i\s+([\d.]+)", re.MULTILINE)
                    area_id = extract_metric(report, r"^\s+id_stage_i\s+([\d.]+)", re.MULTILINE)
                    area_if = extract_metric(report, r"^\s+if_stage_i\s+([\d.]+)", re.MULTILINE)
                    area_lsu = extract_metric(report, r"^\s+load_store_unit_i\s+([\d.]+)", re.MULTILINE)
                    area_rf = extract_metric(report, r"^\s+register_file_i\s+([\d.]+)", re.MULTILINE)

                    row = (
                        period, freq_mhz, wns, tns, slack,
                        area_top, area_core, area_csr, area_ex,
                        area_id, area_if, area_lsu, area_rf,
                        "true" if returncode == 0 else "false"
                    )

                    print(f"  WNS: {wns}  TNS: {tns}  Slack: {slack}")

                else:
                    row = (
                        period, freq_mhz, "null", "null", "null",
                        "null", "null", "null", "null",
                        "null", "null", "null", "null",
                        "false"
                    )

                    print("  Report not found, flow likely failed.")

                # Save CSV row immediately
                write_summary_row(summary_file, row)

                # Copy full reports directory if it exists
                reports_dir = "openroad/reports"
                if os.path.isdir(reports_dir):
                    dst = os.path.join(run_dir, "reports")
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.copytree(reports_dir, dst)

    finally:
        # Always restore original SDC, even if the script crashes or is interrupted
        with open(SDC_PATH, "w") as f:
            f.write(original_sdc)

    print(f"\nSummary saved to {summary_path}")
    print("Original SDC restored.")


def extract_metric(text, pattern, flags=0):
    match = re.search(pattern, text, flags)
    return match.group(1) if match else "null"


if __name__ == "__main__":
    main()