import os
import json
import pytest

SCENARIOS_PATH = os.path.join(os.path.dirname(__file__), 'load_scenarios_300.json')

def load_all_scenarios():
    if os.path.exists(SCENARIOS_PATH):
        with open(SCENARIOS_PATH, 'r') as f:
            return json.load(f)
    return []

scenarios = load_all_scenarios()

def test_TC_LOAD_total_count_uniqueness():
    assert len(scenarios) >= 300, f"Expected at least 300 scenarios, got {len(scenarios)}"
    tc_ids = [s["test_case_id"] for s in scenarios]
    assert len(tc_ids) == len(set(tc_ids)), "Duplicate Test Case IDs found in load testing suite!"

@pytest.mark.parametrize("scenario", scenarios)
def test_individual_load_scenario_schema(scenario):
    required_keys = [
        "test_case_id", "category", "test_case_name", "objective",
        "preconditions", "request_action", "virtual_users",
        "ramp_up_period", "duration", "expected_response_time_ms",
        "expected_status_code", "expected_error_rate_percent", "pass_fail_criteria"
    ]
    for key in required_keys:
        assert key in scenario, f"Scenario {scenario.get('test_case_id')} missing required key '{key}'"
    assert scenario["virtual_users"] > 0
    assert scenario["expected_response_time_ms"] > 0
