#!/usr/bin/python3

from urllib.request import urlopen
from bs4 import BeautifulSoup
import re

response = urlopen('http://promos.privatbank.ua')
data = response.read()
encoding = response.info().get_content_charset()
html = data.decode(encoding)

soup = BeautifulSoup(html, "html.parser")
links_with_text = [a['href'] for a in soup.find_all('a', href=True) if a.text]
r = re.compile("https:\/\/\w+")
https_list = list(filter(r.match, links_with_text))
print("HTTPS LINKS")
for i in https_list:
    print(i)
print("INTERNAL LINKS")
r = re.compile("\/\w+")
nonHTTP_list = list(filter(r.match, links_with_text))
for link in nonHTTP_list:
    print(link)

