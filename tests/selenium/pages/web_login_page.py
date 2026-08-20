from selenium.webdriver.common.by import By
from .web_base_page import WebBasePage

class WebLoginPage(WebBasePage):
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password']")
    SUBMIT_BUTTON = (By.CSS_SELECTOR, "button[type='submit']")
    ERROR_ALERT = (By.CLASS_NAME, "error-alert")

    def login(self, email, password):
        if self.is_displayed(self.EMAIL_INPUT):
            self.send_keys(self.EMAIL_INPUT, email)
            self.send_keys(self.PASSWORD_INPUT, password)
            self.click(self.SUBMIT_BUTTON)
