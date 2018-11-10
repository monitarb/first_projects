# ArtRecommender. 

# Table of Contents
[1. Project Overview](#section-a)  
[2. Actions](#section-b)  
[3. Results](#section-c)  
[4. Summary of insights](#section-d)  


---

## <a name="section-a"></a>1.  Project Overview
The goal of this project is to work with NLP tools to classify works of art in two museums: [MET](https://www.metmuseum.org/) in New York (English) and [Museo del Prado](https://www.museodelprado.es/) in Madrid (Spanish).  
After classifying the paintings using Topic Analysis, we will build a Recommender System from one museum to the other.

---

## <a name="section-b"></a>2.  Actions
Used list of URLs of more than 75k works of art from [MET Museum's GitHub](https://github.com/metmuseum/openaccess)

1. Scrape works of art descriptions from MET's URL using BeautifulSoup
 
2. Build a Topic Model for MET's works of art to match with Prado's topics

3. Scrape URLs from Prado main website, using Selenium and the description inside each URL using BeautifulSoup
 
4. Build a Topic Model for Prado's works of art to match with MET's topics

5. If topics don't match between museums, buils a personalized (art context) Word2Vec translator (Spanish to English)

6. If own Word2Vec translator doesn't work, use [MUSE](https://github.com/facebookresearch/MUSE) predefined Word Vectors and build only one topic model in English

7. Use the results from the unified model to build a content based Recommender System from works of art from one museum to the other
### Tools Used: Python, Pandas, BeautifulSoup, nltk, scikit-learn


---

## <a name="section-c"></a>3.  Results

### Topic Modeling

1. **MET Museum:**  Data was classified into 10 topics: biggest one mixed Religion and Chinese art. 

2. **Prado Museum:**  Data was classified into 8 topics: biggest ones: Religious and Royalty paintings, clearly separated.

3. **Topic Match:**  One on one topic match did not work due to Religion/Chinese topic on Met and the lack of objects (Jewelry, Dress, China) in Museum of Prado


### Day of the Week Recommendation:
![Daily](graphs/Wkdy_Wknd.png)

### Top 15 Recommendations:
![Top15](graphs/Top15Stations.png)

### Time/Hour Recommendation:
![Hourly](graphs/116%20ST.png)


## <a name="section-d"></a>4.  Summary of insights
1. Top 15 Stations (3%) cover 13.5% of foot traffic
2. Stations near Universities and Tech hubs present opportunity for  outreach and awareness. 
3. Stations classified as high per capita income present opportunities for fundraising. 
4. Weekdays mornings not recommended.
5. Overall stations are better targeted between 4-8pm
