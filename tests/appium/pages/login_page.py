from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class LoginPage(BasePage):
    EMAIL_INPUT = (AppiumBy.ACCESSIBILITY_ID, "email_input")
    PASSWORD_INPUT = (AppiumBy.ACCESSIBILITY_ID, "password_input")
    LOGIN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "login_button")
    ERROR_TEXT = (AppiumBy.ACCESSIBILITY_ID, "error_text")

    def enter_email(self, email):
        self.send_keys(self.EMAIL_INPUT, email)

    def enter_password(self, password):
        self.send_keys(self.PASSWORD_INPUT, password)

    def click_login(self):
        self.click(self.LOGIN_BUTTON)

    def login(self, email, password):
        self.enter_email(email)
        self.enter_password(password)
        self.click_login()

    def get_error_message(self):
        return self.get_text(self.ERROR_TEXT)
