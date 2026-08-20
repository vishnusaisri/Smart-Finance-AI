import os
import json
from locust import HttpUser, task, between

SCENARIOS_FILE = os.path.join(os.path.dirname(__file__), 'load_scenarios_300.json')

class SmartFinanceLoadTestUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self):
        self.scenarios = []
        if os.path.exists(SCENARIOS_FILE):
            with open(SCENARIOS_FILE, 'r') as f:
                self.scenarios = json.load(f)

    @task(3)
    def test_dashboard_overview(self):
        self.client.get("/#/dashboard", name="GET /#/dashboard")

    @task(2)
    def test_expenses_list(self):
        self.client.get("/#/expenses", name="GET /#/expenses")

    @task(2)
    def test_budgets_list(self):
        self.client.get("/#/budgets", name="GET /#/budgets")

    @task(1)
    def test_predictions(self):
        self.client.get("/#/predictions", name="GET /#/predictions")

    @task(1)
    def test_add_expense_validation(self):
        payload = {
            "amount": 500,
            "category": "Food & Dining",
            "description": "Load test expense entry",
            "date": "2026-08-17"
        }
        self.client.post("/api/expenses", json=payload, name="POST /api/expenses")
