from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class BudgetPage(BasePage):
    CREATE_BUDGET_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "create_budget_button")
    CATEGORY_INPUT = (AppiumBy.ACCESSIBILITY_ID, "budget_category_input")
    AMOUNT_INPUT = (AppiumBy.ACCESSIBILITY_ID, "budget_amount_input")
    SAVE_BUDGET_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "save_budget_button")
    BUDGET_CARD = (AppiumBy.ACCESSIBILITY_ID, "budget_card")
    EXCEED_WARNING = (AppiumBy.ACCESSIBILITY_ID, "budget_exceed_warning")

    def click_create(self):
        self.click(self.CREATE_BUDGET_BUTTON)

    def fill_budget(self, category, amount):
        self.send_keys(self.CATEGORY_INPUT, category)
        self.send_keys(self.AMOUNT_INPUT, str(amount))

    def save(self):
        self.click(self.SAVE_BUDGET_BUTTON)

    def is_exceed_warning_visible(self):
        return self.is_displayed(self.EXCEED_WARNING)
