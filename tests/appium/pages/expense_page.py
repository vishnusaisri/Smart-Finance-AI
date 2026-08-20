from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class ExpensePage(BasePage):
    ADD_EXPENSE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "add_expense_button")
    AMOUNT_INPUT = (AppiumBy.ACCESSIBILITY_ID, "amount_input")
    NOTES_INPUT = (AppiumBy.ACCESSIBILITY_ID, "notes_input")
    CATEGORY_CHIP = (AppiumBy.ACCESSIBILITY_ID, "category_food")
    SAVE_EXPENSE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "save_expense_button")
    WALLET_WARNING = (AppiumBy.ACCESSIBILITY_ID, "wallet_warning_banner")

    def click_add(self):
        self.click(self.ADD_EXPENSE_BUTTON)

    def fill_expense(self, amount, notes):
        self.send_keys(self.AMOUNT_INPUT, str(amount))
        self.send_keys(self.NOTES_INPUT, notes)
        self.click(self.CATEGORY_CHIP)

    def save(self):
        self.click(self.SAVE_EXPENSE_BUTTON)

    def is_wallet_warning_visible(self):
        return self.is_displayed(self.WALLET_WARNING)
