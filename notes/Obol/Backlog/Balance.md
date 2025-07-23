- [ ] Coinpool should just be ~20 randomized coins per run.
- [ ] Refine monster spawning further. Only a single (or two maybe) neutral monsters capable of spawning each game. The first wave should be hardcoded to be a neutral monster.
- [ ] Make it possible to use patrons multiple times per round; modify the ones where this doesn't make sense (ie Athena/Demeter).


Some thoughts:
- [ ] The game is too long. I would like to greatly reduce the game's runtime.
- [ ] The only direct way to address this is by tackling the number of rounds and/or number of tosses performed each round. 
- [ ] Therefore, I should try reducing the amount of life the player regenerates each round.
- [ ] I should reduce the number of rounds per game. 
- [ ] Goal - 20-30m per run for a fast player (me).
- [ ] Ante - try one of these:

Best Linear Formula: f(x) = 1.600 * x + 0.500
Linear Results:
f(0) = 0.500, Cumulative Sum = 0.500
f(1) = 2.100, Cumulative Sum = 2.600
f(2) = 3.700, Cumulative Sum = 6.300
f(3) = 5.300, Cumulative Sum = 11.600
f(4) = 6.900, Cumulative Sum = 18.500
f(5) = 8.500, Cumulative Sum = 27.000
f(6) = 10.100, Cumulative Sum = 37.100
f(7) = 11.700, Cumulative Sum = 48.800

Best Polynomial Formula: f(x) = 1.270 * x^1.220
Polynomial Results:
f(0) = 0.000, Cumulative Sum = 0.000
f(1) = 1.270, Cumulative Sum = 1.270
f(2) = 2.958, Cumulative Sum = 4.228
f(3) = 4.852, Cumulative Sum = 9.080
f(4) = 6.892, Cumulative Sum = 15.972
f(5) = 9.048, Cumulative Sum = 25.020
f(6) = 11.302, Cumulative Sum = 36.321
f(7) = 13.640, Cumulative Sum = 49.962

Best Exponential Formula: f(x) = 1.680 * 1.360^x
Exponential Results:
f(0) = 1.680, Cumulative Sum = 1.680
f(1) = 2.285, Cumulative Sum = 3.965
f(2) = 3.107, Cumulative Sum = 7.072
f(3) = 4.226, Cumulative Sum = 11.298
f(4) = 5.747, Cumulative Sum = 17.045
f(5) = 7.816, Cumulative Sum = 24.862
f(6) = 10.630, Cumulative Sum = 35.492
f(7) = 14.457, Cumulative Sum = 49.949

Best Logarithmic Formula: f(x) = 1.990 * log(x + 1) + 1.490
Logarithmic Results:
f(0) = 1.490, Cumulative Sum = 1.490
f(1) = 2.869, Cumulative Sum = 4.359
f(2) = 3.676, Cumulative Sum = 8.036
f(3) = 4.249, Cumulative Sum = 12.284
f(4) = 4.693, Cumulative Sum = 16.977
f(5) = 5.056, Cumulative Sum = 22.033
f(6) = 5.362, Cumulative Sum = 27.395
f(7) = 5.628, Cumulative Sum = 33.023

Best Power Law Formula: Power Law: Error, 'c' value not found
Power Law Results:
f(0) = 0.000, Cumulative Sum = 0.000
f(1) = 1.270, Cumulative Sum = 1.270
f(2) = 2.958, Cumulative Sum = 4.228
f(3) = 4.852, Cumulative Sum = 9.080
f(4) = 6.892, Cumulative Sum = 15.972
f(5) = 9.048, Cumulative Sum = 25.020
f(6) = 11.302, Cumulative Sum = 36.321
f(7) = 13.640, Cumulative Sum = 49.962

Best Exponential Decay Formula: f(x) = 1.740 * e^(--0.300 * x)
Exponential Decay Results:
f(0) = 1.740, Cumulative Sum = 1.740
f(1) = 2.349, Cumulative Sum = 4.089
f(2) = 3.170, Cumulative Sum = 7.259
f(3) = 4.280, Cumulative Sum = 11.539
f(4) = 5.777, Cumulative Sum = 17.316
f(5) = 7.798, Cumulative Sum = 25.114
f(6) = 10.526, Cumulative Sum = 35.640
f(7) = 14.209, Cumulative Sum = 49.850


** Process exited - Return Code: 0 **
Press Enter to exit terminal


Python script to generate formulas based on constraints.
```

import numpy as np

# Constants for target cumulative sums (these can be modified before running)
TARGETS = {5: 25, 7: 50}  # Specify targets for any toss number (key is toss index, value is target cumulative sum)

# Linear ante progression formula: f(x) = a * x + b
def linear(x, a, b):
    return a * x + b

# Polynomial ante progression formula: f(x) = a * x^b
def polynomial(x, a, b):
    return a * x ** b

# Exponential ante progression formula: f(x) = a * b^x
def exponential(x, a, b):
    return a * b ** x

# Logarithmic ante progression formula: f(x) = a * log(x+1) + b
def logarithmic(x, a, b):
    return a * np.log(x + 1) + b

# Power Law ante progression formula: f(x) = a * x^c
def power_law(x, a, c):
    return a * x ** c

# Exponential Decay ante progression formula: f(x) = a * e^(-b * x)
def exponential_decay(x, a, b):
    return a * np.exp(-b * x)

# Function to calculate cumulative sum for a given formula and parameters
def calculate_cumulative_sum(formula, a, b, max_toss):
    results = [formula(i, a, b) for i in range(max_toss + 1)]
    cumulative_sum = np.cumsum(results)
    return results, cumulative_sum

# Optimization function to minimize the error in the cumulative sums (brute-force approach)
def optimize_formula_brute_force(formula, max_toss, targets, initial_guess, step_size=0.01, tolerance=1e-4):
    # Try to minimize the squared differences between the cumulative sums and targets by tweaking a and b
    a, b = initial_guess
    best_a, best_b = a, b
    min_error = float('inf')
    
    # Brute-force search for the best parameters
    for a_candidate in np.arange(a - 1, a + 1, step_size):  # Search around initial guess a
        for b_candidate in np.arange(b - 0.5, b + 0.5, step_size):  # Search around initial guess b
            results, cumulative_sum = calculate_cumulative_sum(formula, a_candidate, b_candidate, max_toss)
            error = 0
            for toss_idx, target in targets.items():
                error += (cumulative_sum[toss_idx] - target) ** 2
            if error < min_error:
                min_error = error
                best_a, best_b = a_candidate, b_candidate
    
    return best_a, best_b

# Function to format the formula in human-readable form
def format_formula(formula_type, a, b, c=None):
    if formula_type == 'linear':
        return f"f(x) = {a:.3f} * x + {b:.3f}"
    elif formula_type == 'polynomial':
        return f"f(x) = {a:.3f} * x^{b:.3f}"
    elif formula_type == 'exponential':
        return f"f(x) = {a:.3f} * {b:.3f}^x"
    elif formula_type == 'logarithmic':
        return f"f(x) = {a:.3f} * log(x + 1) + {b:.3f}"
    elif formula_type == 'power_law':
        if c is None:
            return f"Power Law: Error, 'c' value not found"
        return f"f(x) = {a:.3f} * x^{c:.3f}"
    elif formula_type == 'exponential_decay':
        return f"f(x) = {a:.3f} * e^(-{b:.3f} * x)"
    return ""

# Main function to run the experiment
def run_experiment():
    # Get the max toss number from the targets
    max_toss = max(TARGETS.keys())

    # Optimization for Linear Formula using brute force
    initial_guess_linear = [1, 1]  # Initial guess for a and b (for linear formula)
    optimized_params_linear = optimize_formula_brute_force(linear, max_toss, TARGETS, initial_guess_linear)
    a_linear, b_linear = optimized_params_linear
    linear_formula = format_formula('linear', a_linear, b_linear)
    print(f"\nBest Linear Formula: {linear_formula}")
    linear_results, linear_cumulative_sum = calculate_cumulative_sum(linear, a_linear, b_linear, max_toss)
    print("Linear Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {linear_results[i]:.3f}, Cumulative Sum = {linear_cumulative_sum[i]:.3f}")

    # Optimization for Polynomial Formula using brute force
    initial_guess_poly = [1, 1]  # Initial guess for a and b (for polynomial formula)
    optimized_params_poly = optimize_formula_brute_force(polynomial, max_toss, TARGETS, initial_guess_poly)
    a_poly, b_poly = optimized_params_poly
    poly_formula = format_formula('polynomial', a_poly, b_poly)
    print(f"\nBest Polynomial Formula: {poly_formula}")
    poly_results, poly_cumulative_sum = calculate_cumulative_sum(polynomial, a_poly, b_poly, max_toss)
    print("Polynomial Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {poly_results[i]:.3f}, Cumulative Sum = {poly_cumulative_sum[i]:.3f}")

    # Optimization for Exponential Formula using brute force
    initial_guess_exp = [1, 1.2]  # Initial guess for a and b (for exponential formula)
    optimized_params_exp = optimize_formula_brute_force(exponential, max_toss, TARGETS, initial_guess_exp)
    a_exp, b_exp = optimized_params_exp
    exp_formula = format_formula('exponential', a_exp, b_exp)
    print(f"\nBest Exponential Formula: {exp_formula}")
    exp_results, exp_cumulative_sum = calculate_cumulative_sum(exponential, a_exp, b_exp, max_toss)
    print("Exponential Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {exp_results[i]:.3f}, Cumulative Sum = {exp_cumulative_sum[i]:.3f}")

    # Optimization for Logarithmic Formula using brute force
    initial_guess_log = [1, 1]  # Initial guess for a and b (for logarithmic formula)
    optimized_params_log = optimize_formula_brute_force(logarithmic, max_toss, TARGETS, initial_guess_log)
    a_log, b_log = optimized_params_log
    log_formula = format_formula('logarithmic', a_log, b_log)
    print(f"\nBest Logarithmic Formula: {log_formula}")
    log_results, log_cumulative_sum = calculate_cumulative_sum(logarithmic, a_log, b_log, max_toss)
    print("Logarithmic Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {log_results[i]:.3f}, Cumulative Sum = {log_cumulative_sum[i]:.3f}")

    # Optimization for Power Law Formula using brute force
    initial_guess_pl = [1, 1]  # Initial guess for a and c (for power law formula)
    optimized_params_pl = optimize_formula_brute_force(power_law, max_toss, TARGETS, initial_guess_pl)
    a_pl, c_pl = optimized_params_pl
    if c_pl is None:
        pl_formula = "Power Law: Error, 'c' value not found"
    else:
        pl_formula = format_formula('power_law', a_pl, c_pl)
    print(f"\nBest Power Law Formula: {pl_formula}")
    pl_results, pl_cumulative_sum = calculate_cumulative_sum(power_law, a_pl, c_pl, max_toss)
    print("Power Law Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {pl_results[i]:.3f}, Cumulative Sum = {pl_cumulative_sum[i]:.3f}")

    # Optimization for Exponential Decay Formula using brute force
    initial_guess_ed = [1, 0.1]  # Initial guess for a and b (for exponential decay formula)
    optimized_params_ed = optimize_formula_brute_force(exponential_decay, max_toss, TARGETS, initial_guess_ed)
    a_ed, b_ed = optimized_params_ed
    ed_formula = format_formula('exponential_decay', a_ed, b_ed)
    print(f"\nBest Exponential Decay Formula: {ed_formula}")
    ed_results, ed_cumulative_sum = calculate_cumulative_sum(exponential_decay, a_ed, b_ed, max_toss)
    print("Exponential Decay Results:")
    for i in range(max_toss + 1):
        print(f"f({i}) = {ed_results[i]:.3f}, Cumulative Sum = {ed_cumulative_sum[i]:.3f}")

if __name__ == "__main__":
    run_experiment()

```

