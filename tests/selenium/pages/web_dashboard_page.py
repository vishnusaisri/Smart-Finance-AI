from selenium.webdriver.common.by import By
from .web_base_page import WebBasePage

class WebDashboardPage(WebBasePage):
    DASHBOARD_HEADER = (By.XPATH, "//*[contains(text(), 'Dashboard') or contains(text(), 'Welcome')]")
    TOTAL_BALANCE = (By.XPATH, "//*[contains(text(), 'Total Balance')]/..")
    MONTHLY_INCOME = (By.XPATH, "//*[contains(text(), 'Monthly Income')]/..")
    EXPENSES_NAV = (By.XPATH, "//a[contains(@href, 'expenses')]")
    BUDGETS_NAV = (By.XPATH, "//a[contains(@href, 'budgets')]")

    def is_dashboard_loaded(self):
        return self.is_displayed(self.DASHBOARD_HEADER)

    def open_expenses(self):
        self.click(self.EXPENSES_NAV)

    def open_budgets(self):
        self.click(self.BUDGETS_NAV)
