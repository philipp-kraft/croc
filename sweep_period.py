#!/usr/bin/env python3

import subprocess
import shutil
import os
import re
import sys

SDC_PATH = "openroad/src/constraints.sdc"
REPORT_PATH = "openroad/reports/05_core.final.rpt"
RESULTS_DIR = "results/sweep"
FLOW_CMD = "./croc.sh all"

PERIODS = [10.0, 9.5, 9.0, 8.5, 8.0, 7.5, 7.0, 6.5, 6.0, 5.5, 5.0]

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


def main():
    # Read original SDC to restore later
    with open(SDC_PATH, "r") as f:
        original_sdc = f.read()

    os.makedirs(RESULTS_DIR, exist_ok=True)

    summary = []

    for period in PERIODS:
        freq_mhz = 1000.0 / period
        run_name = f"{period:.1f}ns_{freq_mhz:.0f}MHz"
        run_dir = os.path.join(RESULTS_DIR, run_name)
        os.makedirs(run_dir, exist_ok=True)

        print(f"\n{'='*60}")
        print(f"Running: TCK_SYS = {period:.1f} ns ({freq_mhz:.0f} MHz)")
        print(f"{'='*60}")

        # Modify SDC
        modify_sdc(SDC_PATH, period)

        # Run backend
        returncode, log = run_flow()

        # Save build log
        with open(os.path.join(run_dir, "build.log"), "w") as f:
            f.write(log)

        # Copy report
        if os.path.exists(REPORT_PATH):
            shutil.copy2(REPORT_PATH, os.path.join(run_dir, "05_core.final.rpt"))
            # Extract key metrics from report file
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
            summary.append((period, freq_mhz, wns, tns, slack,
                            area_top, area_core, area_csr, area_ex, area_id, area_if, area_lsu, area_rf,
                            "true" if returncode == 0 else "false"))
            print(f"  WNS: {wns}  TNS: {tns}  Slack: {slack}")
        else:
            summary.append((period, freq_mhz, "0", "0", "0",
                            "0", "0", "0", "0", "0", "0", "0", "0",
                            "false"))
            print(f"  Report not found, flow likely failed.")

        # Copy full reports directory if it exists
        reports_dir = "openroad/reports"
        if os.path.isdir(reports_dir):
            dst = os.path.join(run_dir, "reports")
            if os.path.exists(dst):
                shutil.rmtree(dst)
            shutil.copytree(reports_dir, dst)

    # Restore original SDC
    with open(SDC_PATH, "w") as f:
        f.write(original_sdc)

    # Print CSV summary
    header = "period,frequency,wns,tns,slack,area_top,area_i_core,area_cs_registers,area_ex_block,area_id_stage,area_if_stage,area_lsu,area_register_file,status"
    print(f"\n{'='*60}")
    print("SWEEP SUMMARY")
    print(f"{'='*60}")
    print(header)
    for row in summary:
        print(",".join(str(v) for v in row))

    # Save summary as CSV
    summary_path = os.path.join(RESULTS_DIR, "summary.csv")
    with open(summary_path, "w") as f:
        f.write(header + "\n")
        for row in summary:
            f.write(",".join(str(v) for v in row) + "\n")

    print(f"\nSummary saved to {summary_path}")
    print(f"Original SDC restored.")


def extract_metric(text, pattern, flags=0):
    match = re.search(pattern, text, flags)
    return match.group(1) if match else "N/A"


if __name__ == "__main__":
    main()