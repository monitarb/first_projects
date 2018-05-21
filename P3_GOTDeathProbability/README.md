![logo](http://www.hdfondos.eu/pictures/2014/0423/1/orig_61642.jpg)
# A GAME OF THRONES Death Predictor
## *Warning! This repository can contain Spoilers*

# Table of Contents
[1. Project Overview](#section-a)  
[2. Actions](#section-b)  
[3. Results](#section-c)  
[4. Repository Structure](#section-d)  
[5. Sources](#section-e)


---

## <a name="section-a"></a>1.  Project Overview
This project will be focused on Analysis of data from [Game of Thrones](https://www.hbo.com/game-of-thrones) both the book series (Books 1-5) and the HBO tv show (Seasons 1-6) and try to predict the probability of death of living characters on Season 7 for Season 8.  

The focus of these project will be in analysing character features until Book/Season #5, where characters had a similar behaviour, and season #6 where Tv Show's directors and writers took some liberties.  
Character popularity will also be analyzed, to prove the theory that popular characters will mos likely be killed.

**Assumptions**
- On this first version of the Predictor, characters don’t come back to life.  The target valu=es of the model will only be Dead/Alive, so for a character that came back to life, status will be "Alive" in the end of Season 5
- Current dataset only includes human characters (NOT dragons, direwolves, White Walkers or Children of the Forest)
- "House_Book" and "House_Show" refer to the house that the character's loyal to in Book-5 and Season-6 respecively.
- Characters are only classified in the top 10 houses with more members on it (There are "Dummy" House names "Other" and "None" as well)

---

## <a name="section-b"></a>2.  Actions 
1. Load Data from Data Sources

1.1 Books 1-5 Data (Name, Title, Gender, House, Culture, isNoble, isPopular, ...) was loaded from [Kaggle Competition Dataset](https://www.kaggle.com/mylesoneill/game-of-thrones)
 
1.2. Tv Show Seasons 1-6 Data (Name, Gender, Age, House, Popularity, Time on Screen per Season, ...) was loaded from [Raw Data](https://trumpexcel.com/game-of-thrones-dashboard/) from a visual Analysis Project

1.3. Tv Show Specific Data for each Episode (Directors, Writers, Rating, Number of Viewers, Characters per Episode, ...) was loaded from [this GitHub project](https://github.com/mneedham/neo4j-got/blob/master/data)

2. Join Data
> Data between the same Database was joined using SQL to generate more features (isAliveMother, isAliveFather, isAliveSpouse, Number of Episodes per Character, Avergage Rating, average NUmber of viewers, ...)

> Then, Data between those different databases, was joined using Python's FuzzyWuzzy library, to find the best match between Names and Last names in the books vs Tv show

3. Book Analysis:
> First analysis was made only to those characters that appear both in the books and in the tv show simultaneously (212 rows).  Knn, SVM, Logistic Regression, and Random Forests models where generated to find the best preddictor

4. Full Book+Show Analysis
> Full analysis was made to all characters in the books and matching and dummy filling those who matched in the tv show (2011 rows).  Knn, SVM, Logistic Regression, and Random Forests models where generated to find the best preddictor

5. Smote Analysis
> To overcome the unbalance between classes (95%-5%), models using SMOTE data were also analyzed, with no good results.

6. Flask App:
> A web app showing only popular alive characters from season 7, was built using the best predictor found (Random Forest on Full Character Information)

**Tools Used: Python, Pandas, FuzzyWuzzy, Flask, Smote, sklearn**


---

## <a name="section-c"></a>3.  Results

Popularity is a strong feature in determining of a character died or not in the Book Models, but it's importance went down since Season 6.

Screen time suring Season 2 and Season 5 also prove to be a high important "Survival Factor".  Since this is the Season where Show writters separated from the Book Writer original story, this Data Scientist believes that Show writters just *went soft*.  
(*Someone* comming back to life in Season #6 is living proof of that)


## <a name="section-d"></a>4.  Repository Structure
* **/src** : Sorce Folder.  Contains all the scripts used for this analysis with their comment and order.  There are some Scripts to be executed via SQL in a SQL repository (i.e: EC2) and the web app source file
* **/src/models** : Pickle files of all useful models generated, these can be used to change the source that the web app is reading from
* **/src/templates** : html template for the Flask app to use
* **/csv** : .csv File Folder.  Contains all csv files used for this analysis: Source files, temporary files and final files to avoid reloading and transforming data everytime
* **/graphs** : Image Folder.  Contains all images, plots and MVPs produced during this analysis
* **Main Folder**: Project Presentation, summary of process, discoveries and link to GitHub repository


## <a name="section-e"></a>5.  Sources
* [Kaggle Competition](https://www.kaggle.com/mylesoneill/game-of-thrones)

* [Visual Analysis raw data](https://trumpexcel.com/game-of-thrones-dashboard/)

* [Tv Show GitHub project](https://github.com/mneedham/neo4j-got/blob/master/data)

* [Game of Thrones Tv show Wiki](http://gameofthrones.wikia.com/wiki/Game_of_Thrones_Wiki)

* [Song of Ice and Fire Books Wiki](https://awoiaf.westeros.org/index.php/Main_Page)
