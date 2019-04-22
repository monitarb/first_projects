import flask
from flask import request
import pickle
import numpy as np
import pandas as pd


# Initialize the app

app = flask.Flask(__name__)
# These are the two best models found: Choose wisely
# forest_model_otro.pkl
# best_svm_rbf.pkl
with open("models/left_reglog.pkl","rb") as f:
    lr_model = pickle.load(f)

# An example of routing:
# If they go to the page "/" (this means a GET request
# to the page http://127.0.0.1:5000/), return a simple
# page that says the site is up!

@app.route("/")
def hello():
    return "It's alive!!!"


# Let's turn this into an API where you can post input data and get
# back output data after some calculations.

# If a user makes a POST request to http://127.0.0.1:5000/predict, and
# sends an X vector (to predict a class y_pred) with it as its data,
# we will use our trained LogisticRegression model to make a
# prediction and send back another JSON with the answer. You can use
# this to make interactive visualizations.

@app.route("/predict", methods=["POST", "GET"])
def predict():
    #App will load showing Jorah Mormont-s prediction by default
    selected_name = request.args.get("selected_name", "Jorah Mormont")
    
    x_input = lr_model.character_features[lr_model.character_features.name_x==selected_name].iloc[0,2:]
    alive_names = lr_model.character_features[(lr_model.character_features.total_viewers >0.15) & (lr_model.character_features.isdead_shw == 0) ]['name_x']
    
    pred_probs = lr_model.predict_proba([x_input.values])

    return flask.render_template('got.html',
    character_names=alive_names,
    selected_name = selected_name,
    feature_names = lr_model.character_features.columns[2:],
    character_features=x_input,
    prediction=pred_probs[:,1]
    )


# Start the server, continuously listen to requests.
# We'll have a running web app!

# For local development:
app.run(debug=True)