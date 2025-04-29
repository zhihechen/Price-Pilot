# Price Pilot

A Sparkful - Hack To The Top hackathon project to predict airfare using machine learning models and SwiftUI frontend.

## Setup

```bash
git clone https://github.com/zhihechen/Price-Pilot.git
cd Price-Pilot
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Run Backend
### Navigate to the project directory
```bash
cd ai_hack_backend
```
### Start the server
```
uvicorn app:app --reload --host <your_host> --port <your_port>
```

## ML

The machine learning part is located in the `sparkful_ml/` directory.

- **data/**  
  - Contains the dataset for training and testing.  
  - The dataset is sourced from [Kaggle - Flight Price Prediction](https://www.kaggle.com/datasets/shubhambathwal/flight-price-prediction).  
  - The file `Clean_dataset.csv` is the raw data.  
  - You can also run `download.sh` to automatically download the dataset.

- **results/**  
  Stores PNG plots comparing predicted vs. actual prices for each model.  
  We’ve implemented three algorithms (using `scikit-learn`):  
  - **XGBoost (XGB)**  
  - **Gradient Boosting Regressor (GBR)**  
  - **Random Forest (RF)**
  
  After running `training.py`, you’ll find both the generated model files (in `.pkl` format) and the corresponding prediction plots in this folder.

- **training.py**  
  The main training script.  
  You can modify `training.py` to select and train the model you prefer.


## Notes

```text
- Pre-trained .pkl files are too large for this repo; train your own with training.py.
- The backend provides prediction APIs.
- The frontend provides a user interface to input product features.
```

## Demo Video
https://www.youtube.com/shorts/Eo5lxV2EUSE
