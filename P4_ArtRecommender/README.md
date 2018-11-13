# ArtRecommender 

# Table of Contents
[1. Project Overview](#section-a)  
[2. Actions](#section-b)  
[3. Results](#section-c)  
[4. Repository Structure](#section-d)  
[5. Sources](#section-e)


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
**Tools Used: Python, Pandas, BeautifulSoup, nltk, scikit-learn**


---

## <a name="section-c"></a>3.  Results

### Topic Modeling

1. **MET Museum:**  Data was classified into 10 topics: biggest one mixed Religion and Chinese art. 

2. **Prado Museum:**  Data was classified into 8 topics: biggest ones: Religious and Royalty paintings, clearly separated.

3. **Topic Match:**  One on one topic match did not work due to Religion/Chinese topic on Met and the lack of objects (Jewelry, Dress, China) in Museum of Prado

### Word2Vec Translator
1. **Personalized Word2Vec:** Created a Word Vector Space inside the "Art" context, but due to low data volume or unbalanced documents between English-Spanish, it didn't behave as well as preexisting Word Vectors
2. **Best match found: [MUSE](https://github.com/facebookresearch/MUSE)**  was used to translate descriptions from Prado Museum (Spanish) into english
3. **A new topic Model was built:** Using 37 unlabeled topics.  Labels were no longer needed, since we don't want to match between museums anymore.  Separation (Inertia) between topics seems to improve due to the new English-translated data. (i.e: Religion/Chinese group was finally separated thanks to the amount of religious data given by Prado Museum)

### Recommender System:
Using the probabilities to belong to each ef the 37 topics as attributes, a Recommeder System based on contents was built, using Cosine Distance. A filter by artist was used to avoid obvious recommendations  
Results from the Recommender Systems were satisfactory, inside one museums and across museums.  Recommendations were not limited to type (Painting, Ceramic, Painted, glass), artist, year or museum classification.

---

## <a name="section-d"></a>4.  Repository Structure
* **/src** : Sorce Folder.  Contains all the scripts used for this analysis with their comment and order.
* **/files** : Temporary File Folder.  Contains all files generated during this analysis to avoid reloading and transforming data everytime
* **/MetFiles** : Descriptions scraped from [MET](https://www.metmuseum.org/) 
* **/PradoFiles** : Descriptions scraped from [Museo del Prado](https://www.museodelprado.es/)
* **/utils** : Contains all thrird party files used in this analysis: Chrome Driver for iOS, stop words in spanish, word Vectors dwloaded from [MUSE](https://github.com/facebookresearch/MUSE), etc.
* **/models** : Models generated in this analysis for Prado only, MET only, Word2Vec and final
* **Main Folder**: Project Presentation, summary of process, discoveries and link to GitHub repository

---

## <a name="section-e"></a>5.  Sources
* MET Museum GitHub (https://github.com/metmuseum/openaccess):  Main attibutes from works of art including URL to official website, NOT including description (Retrieved 20-05-2018)
* MET Museum Official Website (https://www.metmuseum.org/): Description from the works of art in the URLs retrieved from GitHub (Scrapped 20-05-2018) 
* Museo del Prado Official Website (https://www.museodelprado.es/): Description from the works of art in the Main page - Full collection (Scrapped 22-05-2018) 
* Multilingual Unsupervised or Supervised word Embeddings [MUSE](https://github.com/facebookresearch/MUSE): A. Conneau*, G. Lample*, L. Denoyer, MA. Ranzato, H. Jégou, Word Translation Without Parallel Data (Retrieved 20-05-2018)
* Stop-Word-ISO (https://github.com/stopwords-iso): Stop word list in spanish (Retrieved 21-05-2018)

