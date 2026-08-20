from selenium.webdriver.common.by import By
from .web_base_page import WebBasePage

class WebBudgetPage(WebBasePage):
    CREATE_BUDGET_BUTTON = (By.XPATH, "//*[contains(text(), 'Create Budget')]")
    CATEGORY_INPUT = (By.XPATH, "//input[contains(@hint, 'Food')]")
    AMOUNT_INPUT = (By.XPATH, "//input[contains(@hint, '5000')]")
    SAVE_BUTTON = (By.XPATH, "//button[contains(text(), 'Create') or contains(text(), 'Save')]")
    BUDGET_WARNING_BANNER = (By.XPATH, "//*[contains(text(), 'cannot exceed available wallet balance')]")

    def enter_budget_details(self, category, amount):
        if self.is_displayed(self.CATEGORY_INPUT):
            self.send_keys(self.CATEGORY_INPUT, category)
        if self.is_displayed(self.AMOUNT_INPUT):
            self.send_keys(self.AMOUNT_INPUT, str(amount))

    def is_budget_exceed_warning_present(self):
        return self.is_displayed(self.BUDGET_WARNING_BANNER)
