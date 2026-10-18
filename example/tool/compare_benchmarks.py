#!/usr/bin/env python3
"""Compare two measured AresEdge workbench JSON reports without uploading them.

Positive timing deltas mean the candidate took longer. This is descriptive, not
an automatic release gate or a test of statistical significance.
"""
import argparse
import json
import math
from pathlib import Path


def read_report(path):
    report = json.loads(path.read_text())
    if report.get('schemaVersion') != 1 or report.get('measurement') != 'captureCallbackAndFlutterFrames':
        raise ValueError(f'{path}: unsupported workbench report')
    for key in ['deviceLabel', 'os', 'osVersion', 'buildMode']:
        if not isinstance(report.get(key), str) or not report[key].strip():
            raise ValueError(f'{path}: missing {key}; label the device and conditions before measuring')
    for key in ['captureCallback', 'flutterBuild', 'flutterRaster']:
        metric = report.get(key)
        if not isinstance(metric, dict) or not isinstance(metric.get('samples'), int) or metric['samples'] < 0:
            raise ValueError(f'{path}: invalid {key} sample count')
        for name in ['meanMs', 'p50Ms', 'p95Ms']:
            value = metric.get(name)
            if metric['samples'] == 0:
                if value is not None:
                    raise ValueError(f'{path}: empty metric must have null timings')
            elif isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or value < 0:
                raise ValueError(f'{path}: invalid {key}.{name}')
    if report['captureCallback']['samples'] == 0:
        raise ValueError(f'{path}: collect capture samples before comparing')
    return report


def compare(baseline, candidate, allow_configuration_change=False):
    # Avoid presenting different devices/scenes as a like-for-like SDK regression.
    for key in ['deviceLabel', 'os', 'osVersion', 'buildMode', 'targetRefreshHz', 'warmupSeconds']:
        if baseline.get(key) != candidate.get(key):
            raise ValueError(f'Comparison conditions differ: {key}')
    configuration_changed = baseline.get('configuration') != candidate.get('configuration')
    if configuration_changed and not allow_configuration_change:
        raise ValueError('Configuration differs; use --allow-configuration-change for a deliberate settings experiment')
    lines = ['AresEdge measured timing comparison (candidate versus baseline)']
    if configuration_changed:
        lines.append('Different configurations: deliberate settings experiment, not a like-for-like regression check.')
    for metric in ['captureCallback', 'flutterBuild', 'flutterRaster']:
        before, after = baseline[metric], candidate[metric]
        lines.append(f"{metric}: {before['samples']} -> {after['samples']} retained samples")
        for name in ['meanMs', 'p50Ms', 'p95Ms']:
            a, b = before.get(name), after.get(name)
            if a is None or b is None:
                lines.append(f'  {name}: unavailable (no measured samples)')
                continue
            change = f'{100 * (b - a) / a:+.1f}%' if a else 'percent unavailable (zero baseline)'
            lines.append(f'  {name}: {a:.2f} -> {b:.2f} ms ({b-a:+.2f} ms; {change})')
    lines.append(f"Observed errors: {baseline.get('errors')} -> {candidate.get('errors')}")
    lines.append('Native camera FPS and inference latency are not measured by this harness.')
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('--allow-configuration-change', action='store_true')
    args = parser.parse_args()
    try:
        print(compare(read_report(args.baseline), read_report(args.candidate), args.allow_configuration_change))
    except (ValueError, OSError) as error:
        parser.exit(2, f'{error}\n')


if __name__ == '__main__':
    main()
