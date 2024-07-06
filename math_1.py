import matplotlib.pyplot as plt

# Data points
l = [0.1, 0.14, 0.17, 0.2, 0.22]
t = [5, 10, 15, 20, 25]

# Create a figure and axis
fig, ax = plt.subplots()

# Plot the data points
ax.plot(t, l, 'o-', label='l vs t')  # 'o-' indicates points with lines

# Set the labels and title
ax.set_xlabel('t')
ax.set_ylabel('l')
ax.set_title('Plot of l vs t')

# Set the scale for x-axis and y-axis
ax.set_xticks([5, 10, 15, 20, 25])
ax.set_yticks([0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.24])

# Add gridlines for better readability
ax.grid(True)

# Show legend
ax.legend()

# Show the plot
plt.show()
