#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unicodedata
import io
import os
import sys
import urllib
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import argparse
import csv
import multiprocessing as mp


# download chromedriver
# https://chromedriver.chromium.org/downloads

# install dependencies
# pip install selenium argparse

class YoutubeCrawler:
    YOUTUBE_SEARCH_URL = 'https://www.youtube.com/results?search_query=%s&sp=CAMSAhAB&page=%d'
    headers = ['author', 'link', 'title', 'views', 'like', 'unlike', 'date', 'subscribers', 'comments']
    continue_zero = {}
    cache_ids = []
    records = []
    output_file = None

    def __init__(self, query=[], max_page=1, headless=True, outfile="output.csv", input_file=""):
        self.query = query
        self.max_page = max_page
        self.output_csv_file_tpl = outfile
        self.input_file = input_file

        options = Options()
        if headless:
            options.add_argument('--headless')
            options.add_argument('--disable-gpu')
        self.driver = webdriver.Chrome(chrome_options=options)

    def output_csv_file(self):
        now = datetime.now().strftime('%Y%m%d%H%M%S%f')
        items = self.output_csv_file_tpl.split('.')
        items.insert(1, '%s')
        items.insert(2, '.')
        self.output_csv_file_tpl = ''.join(items)
        return self.output_csv_file_tpl % now

    def run(self):
        if self.query and len(self.query) > 0:
            self.runQuery()
        elif self.input_file and len(self.input_file) > 0:
            self.runInputLinks()

    def runQuery(self):
        for q in self.query:
            self.continue_zero[q] = 0
            for i in range(self.max_page):
                self.get_page(q, i)

                if self.continue_zero[q] >= 2:
                    self.records.append('"%s" scraped pages %d' % (q, i))
                    break

        print('====================finished====================')

    def runInputLinks(self, rows = []):
        if not rows or len(rows) == 0:
            rows = self.fetch_links_from_file()
        self.crawl_links(rows)

    def fetch_links_from_file(self):
        rows = []
        if not self.input_file or not os.path.exists(self.input_file):
            return rows

        with open(self.input_file, 'r') as f:
            rander = csv.DictReader(f)
            rows = [i for i in rander]

        start = 0
        # for i, r in enumerate(rows):
        #     if r['link'] == 'https://youtu.be/6tk7VXPgduk':
        #         start = i
        print('start at', start)
        return rows[start:]
    
    def read_header_from_file(self):
        headers = []
        with open(self.input_file, 'r') as f:
            l = f.readline()
            headers = l.split(',')
            headers = sorted(headers)
        return headers
    
    def get_page(self, query, page):
        self.driver.get(self.YOUTUBE_SEARCH_URL %
                        (urllib.parse.quote(query), page))
        # delay of some kind wait for load time.sleep(3) or selenium wait for an element to be visible
        user_data = self.driver.find_elements_by_xpath(
            '//*[@id="video-title"]')
        links = []
        for i in user_data:
            links.append(i.get_attribute('href'))

        print('====================processing page', page + 1, ', links count', len(links))
        if len(links) == 0:
            self.continue_zero[query] += 1

        self.crawl_links(links)

    def crawl_links(self, links):
        wait = WebDriverWait(self.driver, 10)
        for idx, link in enumerate(links):
            try:
                x = link
                if isinstance(link, dict):
                    x = x['link']
                print('===============crawling link %d: %s' % (idx, x))
                v_id = x.strip('https://www.youtube.com/watch?v=')
                if v_id not in self.cache_ids:
                    self.driver.get(x)
                    v_title = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "h1.title.ytd-video-primary-info-renderer yt-formatted-string"))).text
                    v_views = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "div#count yt-view-count-renderer span.view-count"))).text
                    v_date = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "div#date yt-formatted-string"))).text
                    v_like = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "div#top-level-buttons ytd-toggle-button-renderer:nth-of-type(1)"))).text
                    v_unlike = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "div#top-level-buttons ytd-toggle-button-renderer:nth-of-type(2)"))).text
                    v_subscribers = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "yt-formatted-string#owner-sub-count"))).text
                    v_comments_count = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "div#top-level-buttons ytd-toggle-button-renderer:nth-of-type(2)"))).text
                    v_author = wait.until(EC.presence_of_element_located(
                        (By.CSS_SELECTOR, "ytd-channel-name a.yt-formatted-string"))).text
                    print(v_title)
                    row = [
                        v_author,
                        x,
                        unicodedata.normalize('NFKD', v_title).encode('ascii', 'ignore').decode('utf-8'),
                        v_views,
                        v_like,
                        v_unlike,
                        v_date,
                        v_subscribers,
                        v_comments_count
                    ]
                    self.append_to_file(row, link)
                    self.cache_ids.append(v_id)
            except Exception as e:
                print(e)

    def append_to_file(self, row, row_from_file):
        if not self.output_file:
            self.output_file = self.output_csv_file()

        if not os.path.exists(self.output_file):
            # write header
            with io.open(self.output_file, 'w+', encoding='utf-8') as f:
                headers = self.headers
                if self.input_file and len(self.input_file) > 0:
                    headers.extend(self.read_header_from_file())
                f.write(','.join(['"%s"' % h for h in headers]) + '\n')
        
        with io.open(self.output_file, 'a+', encoding='utf-8') as f:
            # append row
            if isinstance(row_from_file, dict):
                keys = row_from_file.keys()
                keys = sorted(keys)
                values = [row_from_file[k] for k in keys]
                row.extend(values)
            
            line = ','.join(['"%s"' % r for r in row]) + '\n'
            f.write(line)

class SmartFormatter(argparse.ArgumentDefaultsHelpFormatter):
    def _fill_text(self, text, width, indent):
        return ''.join([indent + line for line in text.splitlines(True)])

    def _split_lines(self, text, width):
        return text.splitlines()


def parse_args():
    description = u'''
    youbube视频数据抓取脚本

    准备环境：
    
    1，安装python2.7
    2，安装依赖
       pip install selenium argparse
    3，下载chromedriver，根据自己电脑安装的chrome浏览器版本安装对应的驱动器
       下载地址：https://chromedriver.chromium.org/downloads
       然后，解压文件到环境目录下面
    4，运行脚本即可
       python ./youtube.py
    '''
    parser = argparse.ArgumentParser(
        description=description, formatter_class=SmartFormatter)

    parser.add_argument('-q', '--query', nargs='+',
                        help=u'需要查询过滤的字符,多个字符使用空格分开,一个字符包含空格的使用单引号包含住整个字符串')
    parser.add_argument('-o', '--output-file', default='output.csv',
                        help=u'查询结果输出文件，每次生成文件都会加上当前的时间到文件名当中')
    parser.add_argument('-i', '--input-file', help=u'输入文件，从文件中提取youtube视频链接，抓取数据')
    parser.add_argument('-m', '--max-page', default=1000,
                        type=int, help=u'最大查询页数')
    parser.add_argument('-w', '--web', action="store_true",
                        help=u'打开浏览器，默认是不打开浏览器的')

    return parser.parse_args()

def subprocess_execute(rows):
    tc = YoutubeCrawler(headless=True)
    tc.runInputLinks(rows)

def run_in_mutipleprocess(rows, output_file):
    pool = mp.Pool(20)

    def group_by(l, n):
        return [l[i:i + n] for i in range(0, len(l), n)]

    groups = group_by(rows, 500)
    pool.map(subprocess_execute, groups)
    pool.close()
    pool.join()

    file_prefix = output_file.split('.')[0]
    merge_latest_results(file_prefix, len(groups))

def merge_latest_results(file_prefix, count):
    result_files = []
    for root, dirs, files in os.walk(".", topdown=False):
        for fn in files:
            if fn.startswith(file_prefix):
                result_files.append((fn, os.stat(fn).st_mtime))

    result_files.sort(key=lambda i: i[1], reverse=True)
    if len(result_files) > count:
        result_files = result_files[:count]

    header = True
    lines = ['"authur","link","title","views","like","unlike","date","subscribers","comments","create_time","game_code","game_name","id","link","user_id","video_type"']
    for ft in result_files:
        filename = ft[0]
        with io.open(filename, 'r', encoding='utf-8') as f:
            all_lines = f.readlines()
            if not header:
                lines.append(all_lines[0])
            lines.extend(all_lines[1:])

    output_file_name = file_prefix + "merge"
    with open(output_file_name, 'w+', encoding='utf-8') as f:
        for line in lines:
            f.write(line)

if __name__ == '__main__':

    if len(sys.argv) == 1:
        sys.argv.append('--help')

    args = parse_args()

    # ['#BGtube', '#BGtube Prize', '#BGtube Prize', '#2nd BGtube', '#2ndBGtube']
    tc = YoutubeCrawler(query=args.query, max_page=args.max_page,
                        headless=not args.web, outfile=args.output_file, input_file=args.input_file)
    
    rows_in_file = tc.fetch_links_from_file()
    if len(rows_in_file) > 1000:
        run_in_mutipleprocess(rows_in_file, args.output_file)
    else:
        tc.run()

    exit(0)
