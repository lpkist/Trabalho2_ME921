import time
import pyautogui
from selenium import webdriver
from selenium.webdriver.common.by import By
import pandas as pd
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

driver1 = webdriver.Edge()
#driver2 = webdriver.Edge()
url = 'https://www.sciopen.com/journal/join_journal/stage_page?stage=5&id=1451482829318381570&issueIndex=1779770501208150017&issn=2055-6187'
driver1.get(url)
driver1.find_element(By.CSS_SELECTOR, 'div[class="turn-button"]').click()

flag = True
while flag == True:
    pdfs = driver1.find_elements(By.CSS_SELECTOR, 'span[class="link"]')
    if url == "https://www.sciopen.com/journal/join_journal/stage_page?stage=5&id=1451482829318381570&issueIndex=1514143301173411842&issn=2055-6187":
        flag = False
    for i in range(0, len(pdfs)):
        pdfs[i].click()
        time.sleep(2)
        pyautogui.click(x=936, y=151, clicks=1, button='left')  # arrumar a posição do mouse para clicar em um lugar que consiga fazer o download
    time.sleep(30)
    driver1 = webdriver.Edge()
    driver1.get(url)
    driver1.find_element(By.CSS_SELECTOR, 'div[class="turn-button"]').click()
    time.sleep(1)
    url = driver1.current_url
    print(url)
    time.sleep(3)


driver1.quit()

