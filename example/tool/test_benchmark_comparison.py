import copy
import json
from pathlib import Path
import tempfile
import unittest
from compare_benchmarks import compare, read_report

class ComparisonTests(unittest.TestCase):
    def report(self):
        metric = {'samples': 20, 'meanMs': 100.0, 'p50Ms': 90.0, 'p95Ms': 130.0}
        return {'schemaVersion': 1, 'measurement': 'captureCallbackAndFlutterFrames',
                'deviceLabel': 'same test device and scene', 'os': 'android', 'osVersion': 'test',
                'buildMode': 'profile', 'targetRefreshHz': 60, 'warmupSeconds': 2,
                'configuration': {'quality': 'balanced'}, 'errors': 0,
                'captureCallback': metric, 'flutterBuild': copy.deepcopy(metric),
                'flutterRaster': copy.deepcopy(metric)}
    def test_positive_delta_means_slower_candidate(self):
        a = self.report(); b = copy.deepcopy(a); b['captureCallback']['p95Ms'] = 143
        self.assertIn('+10.0%', compare(a, b))
    def test_different_device_or_build_is_rejected(self):
        a = self.report(); b = copy.deepcopy(a); b['deviceLabel'] = 'different device'
        with self.assertRaises(ValueError): compare(a, b)
    def test_configuration_change_must_be_explicit(self):
        a = self.report(); b = copy.deepcopy(a); b['configuration']['quality'] = 'high'
        with self.assertRaises(ValueError): compare(a, b)
        self.assertIn('deliberate settings experiment', compare(a, b, True))
    def test_missing_samples_and_nonfinite_timings_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'report.json'
            for metric in [{'samples': 0, 'meanMs': None, 'p50Ms': None, 'p95Ms': None},
                           {'samples': 1, 'meanMs': float('nan'), 'p50Ms': 1, 'p95Ms': 1}]:
                data = self.report(); data['captureCallback'] = metric; path.write_text(json.dumps(data))
                with self.assertRaises(ValueError): read_report(path)
    def test_valid_report_can_be_loaded(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'report.json'; path.write_text(json.dumps(self.report()))
            self.assertEqual(read_report(path)['captureCallback']['samples'], 20)

if __name__ == '__main__': unittest.main()
