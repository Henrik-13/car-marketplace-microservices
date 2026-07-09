from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import torch
import torch.nn as nn
import joblib
import pandas as pd
import numpy as np
import os
import time

from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

# 1. Modell architektúra (Meg kell egyeznie a betanítottal)
class MLPRegressorTorch(nn.Module):
    def __init__(self, input_size):
        super(MLPRegressorTorch, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(input_size, 512),
            nn.ReLU(),
            nn.Linear(512, 64),
            nn.ReLU(),
            nn.Linear(64, 16),
            nn.ReLU(),
            nn.Linear(16, 1)
        )

    def forward(self, x):
        return self.model(x)

# 2. Bemeneti JSON validációs modell
class CarRequest(BaseModel):
    marca: str
    model: str
    an: int
    km: int
    putere: int
    capacitate_cilindrica: int
    cutie_de_viteze: str
    combustibil: str
    transmisie: str
    caroserie: str
    culoare: str
    addons: str = ""

app = FastAPI(title="Used Car Price Prediction API")

PREDICTION_REQUESTS = Counter(
    "prediction_service_requests_total",
    "Total number of prediction service requests",
    ["method", "endpoint", "status"]
)
PREDICTION_LATENCY = Histogram(
    "prediction_service_request_duration_seconds",
    "Prediction service request duration in seconds",
    ["endpoint"]
)


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

# Globális változók
device = torch.device('cpu') # A mikroszervíz CPU-n fut
ml_model = None
encoder = None
scaler = None
group_stats = None
feature_columns = None

categorical_cols = ['marca', 'model', 'cutie_de_viteze', 'combustibil', 'transmisie', 'caroserie', 'culoare']
numeric_cols = ['km', 'putere', 'capacitate_cilindrica', 'an']

@app.on_event("startup")
def load_artifacts():
    global ml_model, encoder, scaler, group_stats, feature_columns
    try:
        base_dir = os.path.dirname(os.path.dirname(__file__))
        export_dir = os.getenv("MODEL_EXPORT_DIR", os.path.join(base_dir, 'export'))

        encoder = joblib.load(os.path.join(export_dir, 'one_hot_encoder.joblib'))
        scaler = joblib.load(os.path.join(export_dir, 'min_max_scaler.joblib'))
        group_stats = joblib.load(os.path.join(export_dir, 'group_stats.joblib'))
        feature_columns = joblib.load(os.path.join(export_dir, 'feature_columns.joblib'))
        
        input_size = len(feature_columns)
        ml_model = MLPRegressorTorch(input_size=input_size).to(device)
        ml_model.load_state_dict(torch.load(os.path.join(export_dir, 'mlp_model.pth'), map_location=device))
        ml_model.eval()
        print("Artefaktumok sikeresen betöltve!")
    except Exception as e:
        print(f"Hiba a betöltés során: {e}")

@app.post("/predict")
def predict_price(car: CarRequest):
    start_time = time.perf_counter()
    endpoint = "/predict"

    if ml_model is None:
        PREDICTION_REQUESTS.labels("POST", endpoint, "500").inc()
        raise HTTPException(status_code=500, detail="A modell nem töltődött be.")

    try:
        input_data = pd.DataFrame([car.dict()])

        one_hot_encoded = encoder.transform(input_data[categorical_cols])
        one_hot_columns = encoder.get_feature_names_out(categorical_cols)
        one_hot_df = pd.DataFrame(one_hot_encoded, columns=one_hot_columns)

        final_df = pd.concat([input_data[numeric_cols].reset_index(drop=True), one_hot_df], axis=1)

        input_addons = car.addons.split() if car.addons else []
        for col in feature_columns:
            if col not in final_df.columns:
                if col.startswith('addon_') and col.replace('addon_', '') in input_addons:
                    final_df[col] = 1.0
                else:
                    final_df[col] = 0.0

        final_df = final_df[feature_columns]

        scaled_features = scaler.transform(final_df)
        input_tensor = torch.tensor(scaled_features, dtype=torch.float32).to(device)

        with torch.no_grad():
            scaled_prediction = ml_model(input_tensor).item()

        group_name = car.model if car.model in group_stats else car.marca

        if group_name in group_stats:
            mean_price = group_stats[group_name]['mean_price']
            std_price = group_stats[group_name]['std_price']
            if pd.isna(std_price):
                std_price = 1.0
        else:
            mean_price = 10000.0
            std_price = 5000.0

        final_price = (scaled_prediction * std_price) + mean_price

        PREDICTION_REQUESTS.labels("POST", endpoint, "200").inc()
        return {"predictedPrice": round(final_price, 2)}

    except Exception as e:
        PREDICTION_REQUESTS.labels("POST", endpoint, "400").inc()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        PREDICTION_LATENCY.labels(endpoint).observe(time.perf_counter() - start_time)