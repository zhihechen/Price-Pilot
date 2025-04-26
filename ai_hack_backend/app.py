import os
import pandas as pd
import joblib
from enum import Enum
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, validator
from fastapi.middleware.cors import CORSMiddleware

RF_PATH = os.getenv("RF_PATH", "RF_model.pkl")
GBR_PATH = os.getenv("GBR_PATH", "GBR_model.pkl")
XGB_PATH = os.getenv("XGB_PATH", "XGB_model.pkl")

try:
    rf_model  = joblib.load(RF_PATH)
    gbr_model = joblib.load(GBR_PATH)
    xgb_model = joblib.load(XGB_PATH)
except Exception as e:
    raise RuntimeError(f"載入模型失敗：{e}")

AIRLINES = ["AirAsia","Air_India","GO_FIRST","Indigo","SpiceJet","Vistara"]
SOURCE_CITIES = ["Bangalore","Chennai","Delhi","Hyderabad","Kolkata","Mumbai"]
DEST_CITIES   = SOURCE_CITIES
ARRIVAL_TIMES = ["Afternoon","Early_Morning","Evening","Late_Night","Morning","Night"]
DEPARTURE_TIMES = ARRIVAL_TIMES
STOPS_MAPPING = {"zero":0,"one":1,"two_or_more":2}

# Model response
class StopsEnum(str, Enum):
    zero = "zero"; one = "one"; two_or_more = "two_or_more"

default_alias = Field(..., alias="class")
class PredictRequest(BaseModel):
    airline: str
    source_city: str
    departure_time: str
    stops: StopsEnum
    arrival_time: str
    destination_city: str
    travel_class: str = default_alias
    days_left: int

    @validator("airline","source_city","destination_city",
               "departure_time","arrival_time", pre=True)
    def strip_space(cls, v): return v.strip()

    class Config:
        populate_by_name = True

class PredictResponse(BaseModel):
    rf_price:  float
    gbr_price: float
    xgb_price: float

# FastAPI app
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_methods=["POST"], allow_headers=["*"],
)

def build_feature_array(req: PredictRequest):
    feat = {
        "stops": STOPS_MAPPING[req.stops.value],
        "class": 1 if req.travel_class=="Business" else 0,
        "days_left": req.days_left
    }
    for a in AIRLINES:
        feat[f"airline_{a}"] = int(req.airline==a)
    for sc in SOURCE_CITIES:
        feat[f"source_city_{sc}"] = int(req.source_city==sc)
    for dc in DEST_CITIES:
        feat[f"destination_city_{dc}"] = int(req.destination_city==dc)
    for at in ARRIVAL_TIMES:
        feat[f"arrival_time_{at}"] = int(req.arrival_time==at)
    for dt in DEPARTURE_TIMES:
        feat[f"departure_time_{dt}"] = int(req.departure_time==dt)

    cols = rf_model.feature_names_in_
    import pandas as pd
    return pd.DataFrame([feat], columns=cols)

@app.post("/predict", response_model=PredictResponse)
def predict_all(req: PredictRequest):
    INR_TO_TWD = 0.36
    try:
        df = build_feature_array(req)
        rf_pred  = float(rf_model .predict(df)[0]) * INR_TO_TWD
        gbr_pred = float(gbr_model.predict(df)[0]) * INR_TO_TWD
        xgb_pred = float(xgb_model.predict(df)[0]) * INR_TO_TWD
        return PredictResponse(
            rf_price = rf_pred,
            gbr_price= gbr_pred,
            xgb_price= xgb_pred
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"推論失敗：{e}")