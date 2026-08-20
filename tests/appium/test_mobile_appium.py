import pytest
from pages.login_page import LoginPage
from pages.dashboard_page import DashboardPage
from pages.expense_page import ExpensePage
from pages.budget_page import BudgetPage

def test_TC_APP_001_app_launch_and_splash(driver):
    login_page = LoginPage(driver)
    assert login_page.is_displayed(LoginPage.LOGIN_BUTTON)

def test_TC_APP_002_valid_login(driver):
    login_page = LoginPage(driver)
    login_page.login("user@smartfinance.ai", "Password123!")
    dashboard = DashboardPage(driver)
    assert dashboard.is_loaded()

def test_TC_APP_003_invalid_login_credentials(driver):
    login_page = LoginPage(driver)
    login_page.login("invalid@smartfinance.ai", "WrongPass")
    assert "Invalid" in login_page.get_error_message() or login_page.is_displayed(LoginPage.ERROR_TEXT)

def test_TC_APP_004_expense_creation_within_wallet_balance(driver):
    dashboard = DashboardPage(driver)
    dashboard.navigate_to_expenses()
    expense_page = ExpensePage(driver)
    expense_page.click_add()
    expense_page.fill_expense(500, "Grocery items")
    assert not expense_page.is_wallet_warning_visible()
    expense_page.save()

def test_TC_APP_005_expense_creation_exceeding_wallet_warning(driver):
    dashboard = DashboardPage(driver)
    dashboard.navigate_to_expenses()
    expense_page = ExpensePage(driver)
    expense_page.click_add()
    expense_page.fill_expense(9999999, "Luxury Purchase")
    assert expense_page.is_wallet_warning_visible()

def test_TC_APP_006_budget_limit_enforcement(driver):
    dashboard = DashboardPage(driver)
    dashboard.navigate_to_budgets()
    budget_page = BudgetPage(driver)
    budget_page.click_create()
    budget_page.fill_budget("Entertainment", 9999999)
    assert budget_page.is_exceed_warning_visible()
