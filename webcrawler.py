"""
This piece of code is for crawling the website of stepstone to extract job publication details including:
-- Job Title
-- Publication Date
-- Company
-- Location
"""

"""I imported the neccessary libraries to make this possible"""
from bs4 import BeautifulSoup

import requests

from time import sleep # To help in timing how long the code runs or basically after what time lapse does the code expected to rerun

class webScrapingWithPython:

    """
    Create a class to hold all your functions, methods and objects
    """
    global url, url_ab # Declaration of global variables for easy reference in the methods or functions

    url = 'https://www.stepstone.de/5/ergebnisliste.html?ke=english%20speaking%20data%20analyst&suid=9a35400b-7140-4eae-b5f6-f55d692da26b&action=facet_selected%3BdetectedLanguages%3Ben&fdl=en'
    url_ab = 'https://www.stepstone.de'

    def __init__(self):
        """
        Here I declared some instances of the code that would be refer to down the journey
        """
        self.webContent = requests.get(url).text # This object holds the content of the website requested
        self.soup = BeautifulSoup(self.webContent, 'html5lib') # Creating a beautifulsoup object 'soup' to store the parse content from the site


    def scrapJobs(self):
        """
        Used to scrap the website and store its raw html content to the variable 'webContent'
        Soup object stores the parse html content for ease reading
        """
        self.webContent = requests.get(url).text
        self.soup = BeautifulSoup(self.webContent, 'html5lib')
        return self.soup


    def lastPage(self):
        """This code extracts only the end of the page number and converts it to integer"""
        endPage = webScrapingWithPython.scrapJobs(self).find_all('a', class_='PageLink-sc-1v4g7my-0 gwcKwa') # Regular expression 'find_all' finds the 'a' tag of the html
        return int(endPage[-1].text) # Page number converted into integer


    def webCrawler(self):
        """The entire code is put together to perform crawling through the entire number of pages in the website."""

        count = 0
        while count <= webScrapingWithPython.lastPage(self):

            if count == 0:

                job_title = [ul.text for ul in self.soup('h2')]
                company = [div.text for div in self.soup('div') if 'job-item-company-name' in div.get('data-at', [])]
                location = [li.text for li in self.soup('li') if 'job-item-location' in li.get('data-at', [])]
                publish_date = [li.text for li in self.soup('li') if 'job-item-timeago' in li.get('data-at', [])]
                link = [(url_ab + a.get('href')) for a in self.soup('a') if a.get('target')]
                #pagination = self.soup.find('a', title='Nächste').get('href')


                for (job, company, location, publishDate, link) in zip(job_title, company, location, publish_date, link):
                    with open(f'jobPost/{count}.txt', 'w+') as f:
                        f.write(f'Job Title: {job} \n')
                        f.write(f'Company: {company} \n')
                        f.write(f'Location: {location} \n')
                        f.write(f'Published Date: {publishDate} \n')
                        f.write(f'More details: {link} \n')
                    #print(f'Job Title: {job} \n  Company: {company} \n Location: {location} \n Published Date: {publishDate} \n Website: {link} \n')



            else:

                pagination = self.soup.find('a', title='Nächste').get('href')

                self.webContent = requests.get(pagination).text
                self.soup = BeautifulSoup(self.webContent, 'html5lib')

                job_title = [ul.text for ul in self.soup('h2')]
                company = [div.text for div in self.soup('div') if 'job-item-company-name' in div.get('data-at', [])]
                location = [li.text for li in self.soup('li') if 'job-item-location' in li.get('data-at', [])]
                publish_date = [li.text for li in self.soup('li') if 'job-item-timeago' in li.get('data-at', [])]
                link = [(url_ab + a.get('href')) for a in self.soup('a') if a.get('target')]

                for (job, company, location, publishDate, link) in zip(job_title, company, location, publish_date,link):
                    with open(f'jobPost/{count}.txt', 'w+') as f:
                        """This code is meant to write the information extracted into a folder 'jobPost'."""
                        f.write(f'Job Title: {job} \n')
                        f.write(f'Company: {company} \n')
                        f.write(f'Location: {location} \n')
                        f.write(f'Published Date: {publishDate} \n')
                        f.write(f'More details: {link} \n')
                    #print(f'Job Title: {job} \n  Company: {company} \n Location: {location} \n Published Date: {publishDate} \n Website: {link} \n')

            count += 1
            """This if statement is not necessarily needed when one wants the entire pages to be scraped.
               But it can be used to limit the number of pages desired.
            """
            if count == 5: # I limited it to only 5 pages but can be increased
                break

        print(f'Number of web pages scraped: {count}')


def main():
    """
    This function is used to invoke the class.
    """
    w = webScrapingWithPython()

    #w.webCrawler()


if __name__ == '__main__':
    #main()
    """
    This if statement ensures that only what is defined under the main is executed.
    """
    while True:
        """while loop is used to implement the timer"""
        main()
        timeWait = 24
        print(f'Waiting for {timeWait} hours!')
        sleep(timeWait * 60 * 60)