from selenium.webdriver.common.by import By
from .web_base_page import WebBasePage

class WebExpensePage(WebBasePage):
    ADD_EXPENSE_BUTTON = (By.XPATH, "//*[contains(text(), 'Add Expense')]")
    AMOUNT_INPUT = (By.XPATH, "//input[contains(@hint, '0.00') or contains(@placeholder, '0.00')]")
    NOTES_INPUT = (By.XPATH, "//textarea | //input[contains(@hint, 'What was this')]")
    SAVE_BUTTON = (By.XPATH, "//button[contains(text(), 'Save Expense')]")
    WALLET_WARNING_BANNER = (By.XPATH, "//*[contains(text(), 'Insufficient money in the wallet')]")

    def enter_expense_details(self, amount, notes):
        if self.is_displayed(self.AMOUNT_INPUT):
            self.send_keys(self.AMOUNT_INPUT, str(amount))
        if self.is_displayed(self.NOTES_INPUT):
            self.send_keys(self.NOTES_INPUT, notes)

    def is_insufficient_wallet_warning_present(self):
        return self.is_displayed(self.WALLET_WARNING_BANNER)
