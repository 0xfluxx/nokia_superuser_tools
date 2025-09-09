#!/usr/bin/env python3
import pytest
import time
import json
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

nokia = sys.argv[1]

class TestConfigget():
  def setup_method(self, method):
    self.driver = webdriver.Firefox()
    self.vars = {}
  
  def teardown_method(self, method):
    self.driver.quit()
  
  def test_configget(self):
    self.driver.get("https://{nokia}/login.cgi")
    self.driver.implicitly_wait(10)
    self.driver.find_element(By.ID, "username").send_keys("AdminGPON")
    self.driver.find_element(By.ID, "password").send_keys("ALC#FGU")
    self.driver.find_element(By.NAME, "loginBT").click()
    self.driver.implicitly_wait(10)
    self.driver.get("https://{nokia}/usb.cgi?backup")
    self.driver.find_element(By.CSS_SELECTOR, ".buttonText").click()
    self.driver.find_element(By.ID, "outp").click()

  def test_configssend(self):
    self.driver.find_element(By.ID, "filestyle-0").send_keys("/home/user/nokia-cfgs/dropbear")
    self.driver.find_element(By.ID, "imp").click()
    assert self.driver.switch_to.alert.text == "Are you sure to restore configuration file to ONT?"
    self.driver.switch_to.alert.accept()
    self.driver.close()
  

