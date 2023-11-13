# Test ARX model identification and compare to example from MATLAB
# documentation.
#
# This code is based on the example at
# https://apmonitor.com/wiki/index.php/Apps/ARXTimeSeries

from gekko import GEKKO
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

filename = "test_arx_sysid_data.csv"
data_est = pd.read_csv(filename)

# load data and parse into columns
t = data_est.t  
u = data_est.u
y = data_est.y

m = GEKKO()

# system identification
na = 2 # output coefficients
nb = 2 # input coefficients
nk = 1
y_pred, p, K = m.sysid(t, u, y, na, nb, nk, pred='mean', shift='calc')

# Display results
print(p)
print(f"K: {K}")

# Calculate root-mean-squared error
rmse = np.sqrt(np.mean((y.values.reshape(-1, 1) - y_pred) ** 2))
print(f"Root-mean-squared-error: {rmse:.3f}")

plt.figure(figsize=(9, 5.5))
plt.subplot(2,1,1)
plt.plot(t, u, label='u')
plt.legend()
plt.grid()

plt.subplot(2,1,2)
plt.plot(t, y)
plt.plot(t, y_pred)
plt.legend(['y', 'y_pred'])
plt.xlabel('Time')
plt.grid()

plt.tight_layout()
plt.savefig("test_arx_sysid_py_plot.pdf")
plt.show()
