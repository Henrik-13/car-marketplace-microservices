import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
from sklearn.preprocessing import OneHotEncoder, StandardScaler, MinMaxScaler, MultiLabelBinarizer
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, accuracy_score, mean_absolute_error, mean_squared_error, root_mean_squared_error, mean_absolute_percentage_error
from sklearn.utils import shuffle
import time
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
import torch.optim as optim

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(f"Using {device} device")

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

def prepare_data(X_train, X_test, y_train, y_test):
    X_train_tensor = torch.tensor(X_train, dtype=torch.float32).to(device)
    X_test_tensor = torch.tensor(X_test, dtype=torch.float32).to(device)
    y_train_tensor = torch.tensor(y_train.values, dtype=torch.float32).view(-1, 1).to(device)
    y_test_tensor = torch.tensor(y_test.values, dtype=torch.float32).view(-1, 1).to(device)

    train_dataset = TensorDataset(X_train_tensor, y_train_tensor)
    test_dataset = TensorDataset(X_test_tensor, y_test_tensor)

    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

    return train_loader, test_loader

def train_model(model, train_loader, test_loader, epochs=200, learning_rate=0.001):
    # criterion = nn.MSELoss()
    criterion = nn.HuberLoss()
    # optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    optimizer = optim.AdamW(model.parameters(), lr=0.0005, weight_decay=0.1)


    for epoch in range(epochs):
        model.train()
        total_loss = 0
        for X_batch, y_batch in train_loader:
            optimizer.zero_grad()
            y_pred = model(X_batch)
            loss = criterion(y_pred, y_batch)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()

        print(f"Epoch {epoch+1}/{epochs}, Loss: {total_loss / len(train_loader):.4f}")

    return model

def evaluate_model(model, test_loader):
    model.eval()
    predictions, actuals = [], []
    with torch.no_grad():
        for X_batch, y_batch in test_loader:
            X_batch = X_batch.to(device)
            y_batch = y_batch.to(device)
            y_pred = model(X_batch).squeeze()
            predictions.extend(y_pred.cpu().numpy())
            actuals.extend(y_batch.cpu().numpy().squeeze())

    return predictions, actuals

def scale_prices(dataset):
    # Define the grouping name based on frequency
    freq = dataset['model'].value_counts()
    dataset['group_name'] = dataset['model'].where(freq[dataset['model']] >= 20, dataset['marca'])

    # Compute mean and std per group
    group_stats = dataset.groupby('group_name')['pret'].agg(['mean', 'std']).rename(
        columns={'mean': 'mean_price', 'std': 'std_price'})

    # Merge the stats back to the dataset
    dataset = dataset.merge(group_stats, on='group_name', how='left')

    # Standardize the price
    dataset['std_price'] = dataset['std_price'].replace(np.nan, 1)
    dataset['scaled_price'] = (dataset['pret'] - dataset['mean_price']) / dataset['std_price']

    return dataset


def inverse_transform(predictions, dataset):
    # Recover original price from scaled predictions
    predictions_original = (predictions * dataset['std_price'].values) + dataset['mean_price'].values
    return predictions_original


def add_ons(dataset):
    dataset['addons'] = dataset['addons'].fillna('')
    mlb = MultiLabelBinarizer()
    addons_encoded = mlb.fit_transform(dataset['addons'].str.split() if not dataset['addons'].empty else [])
    addons_df = pd.DataFrame(
        addons_encoded,
        columns=[f'addon_{addon}' for addon in mlb.classes_],
        index=dataset.index
    )
    dataset = pd.concat([dataset.drop('addons', axis=1), addons_df], axis=1)

    return dataset

def statistical_filtering(dataset):
    if 'marca' not in dataset.columns or 'model' not in dataset.columns or 'pret' not in dataset.columns:
        raise KeyError("Hiányzó oszlop! Ellenőrizd az adathalmaz oszlopneveit.")

    model_stats = dataset.groupby(['marca', 'model'])['pret'].agg(['mean', 'std', 'count']).reset_index()
    brand_stats = dataset.groupby('marca')['pret'].agg(['mean', 'std', 'count']).reset_index()

    model_stats = model_stats.merge(brand_stats, on='marca', suffixes=('_model', '_brand'), how='left')

    model_stats['mean'] = np.where(
        model_stats['count_model'] < 20,
        model_stats['mean_brand'],
        model_stats['mean_model']
    )
    model_stats['std'] = np.where(
        model_stats['count_model'] < 20,
        model_stats['std_brand'],
        model_stats['std_model']
    )

    model_stats = model_stats[['marca', 'model', 'mean', 'std']]
    dataset = dataset.merge(model_stats, on=['marca', 'model'], how='left')

    dataset = dataset[
        (dataset['pret'] >= dataset['mean'] - 3 * dataset['std']) &
        (dataset['pret'] <= dataset['mean'] + 3 * dataset['std'])
    ]

    dataset.drop(['mean', 'std'], axis=1, inplace=True)
    return dataset


categorical_cols = ['marca', 'model', 'cutie_de_viteze', 'combustibil', 'transmisie', 'caroserie', 'culoare']
numeric_cols = ['km', 'putere', 'capacitate_cilindrica', 'an']

dataset = pd.read_csv('Data/autovit_data_mdpi.csv')
print(dataset.info())
dataset = dataset[(dataset['pret'] < 100000) & (dataset['an'] > 1999) & (dataset['km'] < 500001) & (dataset['putere'] < 600)]
dataset = statistical_filtering(dataset)

dataset = add_ons(dataset)  # with addons
# dataset = dataset.drop(['addons'], axis=1)  # without addons
print(f"Dataset shape after filtering: {dataset.shape}")


dataset = shuffle(dataset, random_state=42)
dataset = scale_prices(dataset)
# y = dataset['pret']
y = dataset['scaled_price']

# y_scaler = MinMaxScaler()
# y_scaled = y_scaler.fit_transform(y.values.reshape(-1, 1)).flatten()

X = dataset.drop(['optiuni_culoare', 'id', 'url', 'pret'], axis=1)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=int(time.time()))
X_test_index = X_test.index

encoder = OneHotEncoder(handle_unknown='ignore', sparse_output=False)
encoder.fit(X_train[categorical_cols])
one_hot_encoded_output_train = encoder.transform(X_train[categorical_cols])
one_hot_encoded_output_test = encoder.transform(X_test[categorical_cols])
one_hot_columns = encoder.get_feature_names_out(categorical_cols)
one_hot_train_df = pd.DataFrame(one_hot_encoded_output_train, columns=one_hot_columns, index=X_train.index)
one_hot_test_df = pd.DataFrame(one_hot_encoded_output_test, columns=one_hot_columns, index=X_test.index)

X_train_final = pd.concat([X_train[numeric_cols], one_hot_train_df], axis=1)
X_test_final = pd.concat([X_test[numeric_cols], one_hot_test_df], axis=1)

scaler = MinMaxScaler()
X_train_new = scaler.fit_transform(X_train_final)
X_test_new = scaler.transform(X_test_final)

train_loader, test_loader = prepare_data(X_train_new, X_test_new, y_train, y_test)
model = MLPRegressorTorch(input_size=X_train_new.shape[1]).to(device)
model = train_model(model, train_loader, test_loader)
predictions, actuals = evaluate_model(model, test_loader)

actuals_original = inverse_transform(actuals, dataset.iloc[X_test_index])
predictions_original = inverse_transform(predictions, dataset.iloc[X_test_index])

print(root_mean_squared_error(actuals_original, predictions_original))
print(r2_score(actuals_original, predictions_original))
print(mean_absolute_error(actuals_original, predictions_original))
print(mean_absolute_percentage_error(actuals_original, predictions_original))

# --- EXPORTING SECTION FOR THE MICROSERVICE ---
import joblib
import os

print("Exporting artifacts for the microservice...")
os.makedirs('export', exist_ok=True)

# 1. Saving the model weights
torch.save(model.state_dict(), 'export/mlp_model.pth')

# 2. Saving the scalers and encoders
joblib.dump(encoder, 'export/one_hot_encoder.joblib')
joblib.dump(scaler, 'export/min_max_scaler.joblib')

# 3. Saving group statistics for inverse transformation
# We recalculate the scale_prices logic for export purposes
freq = dataset['model'].value_counts()
temp_group_name = dataset['model'].where(freq[dataset['model']] >= 20, dataset['marca'])
group_stats_df = dataset.groupby(temp_group_name)['pret'].agg(['mean', 'std']).rename(
    columns={'mean': 'mean_price', 'std': 'std_price'}
)
joblib.dump(group_stats_df.to_dict('index'), 'export/group_stats.joblib')

# 4. Saving the final column names order (Critical for prediction)
joblib.dump(list(X_train_final.columns), 'export/feature_columns.joblib')

print("Exporting artifacts successful! Copy the 'export' folder to the root of the prediction-service.")