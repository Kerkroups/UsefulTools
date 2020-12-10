#!/usr/bin/python3

from urllib.request import urlopen
from bs4 import BeautifulSoup
import re, sys
from optspec import getopt

def main (argv):

    sitename = ""
    try:
        opts, args = getopt.getopt(argv,"hu:",["url="])
    except getopt.GetoptError:
        print ('LinkCrawl.py -u <https://sitename>')
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print ('LinkCrawl.py -u <https://sitename>')
            sys.exit()
        elif opt in ("-u", "--url"):
            sitename = str(arg)

    response = urlopen(sitename)
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

if __name__ == "__main__":
   main(sys.argv[1:])
