import time
from selenium import webdriver
from selenium.webdriver.common.by import By
import pandas as pd
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

driver1 = webdriver.Edge()
driver2 = webdriver.Edge()
driver3 = webdriver.Edge()
driver4 = webdriver.Edge()
driver5 = webdriver.Edge()

links = pd.read_csv("C:/Users/Lucas/Documents/Disciplinas/7o S/Aprendizado de Máquina Não Supervisionado/Trabalho 1/links.csv")
links = links["url"]

driver1.get('https://tubemp3.to/')
driver2.get('https://tubemp3.to/')
driver3.get('https://tubemp3.to/')
driver4.get('https://tubemp3.to/')
driver5.get('https://tubemp3.to/')


for j in range(links.count()//5):
    i = 5*j
    print(i)
    driver1.fullscreen_window()
    driver1.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').clear()
    driver1.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').send_keys(links[i])
    time.sleep(2)
    driver1.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
    time.sleep(5)
    driver1.find_element(By.CSS_SELECTOR, 'div[class="download-mp3"]').click()
    time.sleep(10)
    driver1.find_element(By.CSS_SELECTOR, 'a[class="download-mp3-url btn audio q128"]').click()
    time.sleep(30)
    i = i + 1
    driver2.fullscreen_window()
    driver2.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').clear()
    driver2.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').send_keys(links[i])
    time.sleep(2)
    driver2.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
    time.sleep(5)
    driver2.find_element(By.CSS_SELECTOR, 'div[class="download-mp3"]').click()
    time.sleep(10)
    driver2.find_element(By.CSS_SELECTOR, 'a[class="download-mp3-url btn audio q128"]').click()
    time.sleep(30)
    i = i + 1
    driver3.fullscreen_window()
    driver3.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').clear()
    driver3.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').send_keys(links[i])
    time.sleep(2)
    driver3.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
    time.sleep(5)
    driver3.find_element(By.CSS_SELECTOR, 'div[class="download-mp3"]').click()
    time.sleep(10)
    driver3.find_element(By.CSS_SELECTOR, 'a[class="download-mp3-url btn audio q128"]').click()
    time.sleep(30)
    i = i + 1
    driver4.fullscreen_window()
    driver4.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').clear()
    driver4.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').send_keys(links[i])
    time.sleep(2)
    driver4.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
    time.sleep(5)
    driver4.find_element(By.CSS_SELECTOR, 'div[class="download-mp3"]').click()
    time.sleep(10)
    driver4.find_element(By.CSS_SELECTOR, 'a[class="download-mp3-url btn audio q128"]').click()
    time.sleep(30)
    i = i + 1
    driver5.fullscreen_window()
    driver5.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').clear()
    driver5.find_element(By.CSS_SELECTOR, 'input[name="videoURL"]').send_keys(links[i])
    time.sleep(2)
    driver5.find_element(By.CSS_SELECTOR, 'button[type="submit"]').click()
    time.sleep(5)
    driver5.find_element(By.CSS_SELECTOR, 'div[class="download-mp3"]').click()
    time.sleep(10)
    driver5.find_element(By.CSS_SELECTOR, 'a[class="download-mp3-url btn audio q128"]').click()
    time.sleep(30)

driver1.quit()
driver2.quit()
driver3.quit()
driver4.quit()
driver5.quit()
