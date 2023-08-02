import numpy as np
import matplotlib.pyplot as plt
s
def simulate_game(turns=100, threshold=10):
    """Simulate a game with a given threshold and the option to stop rolling"""
    current_value = 1
    total_winnings = 0
    games_played = 0
    while games_played < turns:
        if current_value > threshold:
            # If the current value is above the threshold, stop rolling and collect the current value for the remaining turns
            remaining_turns = turns - games_played
            total_winnings += current_value * remaining_turns
            break
        else:
            # If the current value is not above the threshold, roll the die
            current_value = np.random.choice(range(1, 21))
            total_winnings += current_value
            games_played += 1
    return total_winnings

# Simulate 10,000 games with various thresholds
num_trials = 100000  # Use fewer games to speed up the simulation
thresholds = list(range(1, 21))  # Try thresholds from 1 to 20

mean_winnings = []
for threshold in thresholds:
    winnings = [simulate_game(threshold=threshold) for _ in range(num_trials)]
    mean_winnings.append(np.mean(winnings))

mean_winnings
# Plot average winnings as a function of threshold

plt.figure(figsize=(10, 6))
plt.plot(thresholds, mean_winnings, marker='o')
plt.xlabel('Threshold')
plt.ylabel('Average Winnings')
plt.title('Average Winnings vs Threshold')
plt.grid(True)
plt.show()