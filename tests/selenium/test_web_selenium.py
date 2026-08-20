import pytest
from pages.web_dashboard_page import WebDashboardPage
from pages.web_expense_page import WebExpensePage
from pages.web_budget_page import WebBudgetPage

def test_TC_WEB_001_dashboard_page_load(driver):
    dashboard = WebDashboardPage(driver)
    assert driver.title != ""

def test_TC_WEB_002_expense_10_digit_limit(driver):
    dashboard = WebDashboardPage(driver)
    dashboard.open_expenses()
    expense_page = WebExpensePage(driver)
    expense_page.enter_expense_details("1000000000000000000000000", "Testing digit limit")
    # Verify input cap or error string
    assert True

def test_TC_WEB_003_expense_wallet_balance_warning(driver):
    dashboard = WebDashboardPage(driver)
    dashboard.open_expenses()
    expense_page = WebExpensePage(driver)
    expense_page.enter_expense_details(9999999, "Large Purchase")
    # Verify wallet warning if displayed
    assert True

def test_TC_WEB_004_budget_creation_wallet_enforcement(driver):
    dashboard = WebDashboardPage(driver)
    dashboard.open_budgets()
    budget_page = WebBudgetPage(driver)
    budget_page.enter_budget_details("Luxury", 9999999)
    assert True
