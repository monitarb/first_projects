import scrapy

# Scrapy Spider that will scrape information from Weather Underground (www.wunderground.com) for Armenia, Colombia
class WeatherSpider(scrapy.Spider):
    name = 'weather_spider'

    custom_settings = {
        "DOWNLOAD_DELAY": 3,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 3,
        "HTTPCACHE_ENABLED": True
    }

    start_urls = [
        # SKAR: IATA code for Armania
        # 2010/1: Beggining date to start scraping
	# It's the first date will complete and accurate weather data
        'https://www.wunderground.com/history/airport/SKAR/2010/1/10/MonthlyHistory.html'
    ]

    def parse(self, response):
        # Generate data for each of the months (page by page)
        print('##### '+response.url)
        yield scrapy.Request(url= response.url,
                             callback=self.parse_month,
                             meta={'url':response.url}
                            )
        
        # Get next URL from "Next Month* button
        next_url = response.xpath('//div[@class="next-link"]/a/@href').extract()[0].strip()
        next_url = 'https://www.wunderground.com' + next_url
        
        # Call the same spder over the new URL
        yield scrapy.Request(url=next_url, callback=self.parse, dont_filter=True)

    def parse_month(self, response):
        # Get information for each webpage
        url = response.request.meta['url']
        print(url)
        
        # Year: Title, split by coma to separate from month
        year = response.xpath('//h2[@class="history-date"]/text()').extract()[0].split()[-1]
        
        # Month: Title, split by coma to separate from month
        month = response.xpath('//h2[@class="history-date"]/text()').extract()[0].split()[-2][:-1]
        
        # Average Temperature: position 4 from list of wx-values in history-date table
        avg_tmp = response.xpath(
            '//table[@id="historyTable"]/tbody/tr/td/span/span[@class="wx-value"]/text()'
        ).extract()[4]

        # Dew Point: position 10 from list of wx-values in history-date table
        dew_point = (response.xpath(
            '//table[@id="historyTable"]/tbody/tr/td/span/span[@class="wx-value"]/text()'
        ).extract()[10])

        # Average Precipitations: position 13 from list of wx-values in history-date table
        avg_precip = (response.xpath(
            '//table[@id="historyTable"]/tbody/tr/td/span/span[@class="wx-value"]/text()'
        ).extract()[13])

        # Sum of Monthy Precipitations: position 15 from list of wx-values in history-date table
        sum_precip = (response.xpath(
            '//table[@id="historyTable"]/tbody/tr/td/span/span[@class="wx-value"]/text()'
        ).extract()[15])

        # Average Wind Speed: position 17 from list of wx-values in history-date table
        avg_wind = (response.xpath(
            '//table[@id="historyTable"]/tbody/tr/td/span/span[@class="wx-value"]/text()'
        ).extract()[17])
        
        # Average Humidity: Get list of Humidity Daily
        obsTable_raw = response.xpath(
            '//table[@id="obsTable"]/tbody/tr/td'
        ).extract()
        
        #Get only the Avg. Humidity Value for each day
        raw_list=[obsTable_raw[29+21*i] for i in range(0,28)]
        day_humidity = [x.split('>')[2].split('<')[0] for x in raw_list]

        # Build all the data into a dictionary for one page (Year-Month)
        yield {'year': year,
               'month': month,
               'avg_tmp': avg_tmp,
               'dew_point': dew_point,
               'avg_precip': avg_precip,
               'sum_precip': sum_precip,
               'avg_wind': avg_wind,
               'day_humidity': day_humidity
        }
