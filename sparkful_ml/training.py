import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from xgboost import XGBRegressor
import joblib  # Add joblib import

# Load and explore dataset
df = pd.read_csv('./Clean_Dataset.csv')
'''print(df.head())
print(df.shape)
print(df.describe())
print(df.columns)
print(df.airline.value_counts())
print(df.source_city.value_counts())
print(df.destination_city.value_counts())
print(df.departure_time.value_counts())
print(df.arrival_time.value_counts())
print(df.stops.value_counts())
print(df['class'].value_counts())'''

# Data Preprocessing
df = df.drop('Unnamed: 0', axis=1)
df = df.drop('flight', axis=1)
df['class'] = df['class'].apply(lambda x: 1 if x == 'Business' else 0)
df.stops = pd.factorize(df.stops)[0]
df = df.join(pd.get_dummies(df.airline, prefix='airline')).drop('airline', axis=1)
df = df.join(pd.get_dummies(df.source_city, prefix='source_city')).drop('source_city', axis=1)
df = df.join(pd.get_dummies(df.destination_city, prefix='destination_city')).drop('destination_city', axis=1)
df = df.join(pd.get_dummies(df.arrival_time, prefix='arrival_time')).drop('arrival_time', axis=1)
df = df.join(pd.get_dummies(df.departure_time, prefix='departure_time')).drop('departure_time', axis=1)

print(df.head())

name = 'XGB'

# Train the model
X = df.drop(columns=['price','duration'])
y = df['price']
# df.to_csv('data.csv', index=False)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
reg = XGBRegressor(n_estimators=100, learning_rate=0.1, n_jobs=-1, random_state=42)
# reg = RandomForestRegressor(n_jobs=-1)
# reg = DecisionTreeRegressor(max_depth=5, random_state=42)
# reg = GradientBoostingRegressor(n_estimators=100, learning_rate=0.1, random_state=42)
reg.fit(X_train, y_train)
print('Training R²:', reg.score(X_train, y_train))
print('Test R²:', reg.score(X_test, y_test))

# Evaluate the model
y_pred = reg.predict(X_test)
print('R²:', r2_score(y_test, y_pred))
print('MAE:', mean_absolute_error(y_test, y_pred))
print('MSE:', mean_squared_error(y_test, y_pred))

# Save the trained model
joblib.dump(reg, f'{name}_model.pkl')
print("Model saved as 'model.pkl'")

# Plot actual vs. predicted prices
plt.figure(figsize=(8, 5))
plt.scatter(y_test, y_pred, alpha=0.40)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', label='y = x')  # Add y=x line
plt.xlabel('Actual Flight Price')
plt.ylabel('Predicted Flight Price')
plt.title(f"{name} Prediction vs Actual Price", fontsize=20)
plt.legend()  # Show legend for y=x line
plt.savefig(f'price_prediction_{name}.png')  # Save as PNG
plt.close()