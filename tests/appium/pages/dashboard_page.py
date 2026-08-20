from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class DashboardPage(BasePage):
    WELCOME_HEADER = (AppiumBy.ACCESSIBILITY_ID, "welcome_header")
    TOTAL_BALANCE = (AppiumBy.ACCESSIBILITY_ID, "total_balance_card")
    MONTHLY_INCOME = (AppiumBy.ACCESSIBILITY_ID, "monthly_income_card")
    MONTHLY_EXPENSES = (AppiumBy.ACCESSIBILITY_ID, "monthly_expenses_card")
    EXPENSES_TAB = (AppiumBy.ACCESSIBILITY_ID, "expenses_tab")
    BUDGETS_TAB = (AppiumBy.ACCESSIBILITY_ID, "budgets_tab")

    def is_loaded(self):
        return self.is_displayed(self.WELCOME_HEADER)

    def get_total_balance(self):
        return self.get_text(self.TOTAL_BALANCE)

    def navigate_to_expenses(self):
        self.click(self.EXPENSES_TAB)

    def navigate_to_budgets(self):
        self.click(self.BUDGETS_TAB)
