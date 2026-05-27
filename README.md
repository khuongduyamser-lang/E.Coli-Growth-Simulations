# E.Coli-Growth-Simulations
This model is created to try simulating the growth of E.Coli model under different initial parameters (Inoculum size, Dilution factor) and constant temperature and LB medium. This model also integrates the lag term of Fujikawa et al. (2004) and the death kinetics of Krce et al. (2019). The UI can also be found and used in MATLAB.

## Overview
Standard microbial model frequently fail to capture the initial lag phase and the final death phase observed in batch cultures. This project tries to tackle this by synthesizing the idea of two peer-reviewed frameworks: 
1. **Krce et al. (2019)**: Provides an innovative quadratic bacterium-bacterium interaction term to accurately model nutrient depletion and the death phase.
2. **Fujikawa et al. (2004):** Provides an empirical term to simulate intial lag constraints when cells adapt to environmental parameters.

## Mathematical model
The simulator evaluates the normalized bacterial concentration b(t) = B(t)/N0 and nutrient concentration n(t) = N(t)/N0 using the following diffrential equation: 
dq/dt = x / (x + 0.093)
db/dt = q(x) *(1.94e-2 * b * n - 1.96e-4*b^2) * (1 - Bmin/B(t))^0.72
dn/dt = -q(x) * 1.94e-2 * b * n * (1 - Bmin/B(t))^0.72
where: 
- x represents the initial dilution factor of the growth medium (compared to 100% LB medium)
- q(x) is the nutrion uptake 
- (1 - Bmin/B(t))^0.72 serves as the initial lag term

## UI controls
- **Inoculum Size Control:** Set custom starting cell concentrations (scaled to 10^8 CFU/ml).
- **Dilution Factor Control:** Adjust the nutritional richness of the Lysogeny Broth (LB) medium (limit from 0 to 1)
- **Simulation Timeline:** minutes
- **Multi-Model Plotting:**
  - **Run Button:** Computes and displays the Project Model curve using an automated ode45 solver execution.
  - **Compare Button:** Overlays baseline plots from the independent Krce and Fujikawa models.
  - **Clear Button:** Resets visual axes for fresh data evaluations.
 
## Requirements & Installation
1. Clone this repository to your local machine.
2. Ensure you have **MATLAB** installed along with the **Simulink/Ordinary Differential Equation Solvers toolbox**.
3. Open MATLAB, navigate to the AppDesigner, and run `EColi_Simulator.mlapp`.

## References
- Fujikawa, H., Kai, A., & Morozumi, S. (2004). A new logistic model for Escherichia coli growth at constant and dynamic temperatures. *Food Microbiology*, 21(5), 501–509.
- Krce, L., Šprung, M., Maravić, A., & Aviani, I. (2019). A simple interaction-based E. coli growth model. *Physical Biology*, 16(6), Article 066005.
