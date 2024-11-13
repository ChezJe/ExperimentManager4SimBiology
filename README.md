# Automatically testing fitting options with Experiment Manager and SimBiology

Selecting the right settings for parameter estimation might require multiple trials.

This repository contains examples of running batch fitting tasks with SimBiology using Experiment Manager.

[Experiment Manager](https://www.mathworks.com/help/matlab/ref/experimentmanager-app.html) in MATLAB is a tool designed to streamline and manage the process of running and comparing multiple experiments. It organizes, configures, and executes experiments, enabling users to track results, visualize metrics, and analyze outcomes for finding the optimal parameters for their task.

Two examples are included:

1. **Nonlinear regression -** an example where a mPBPK-PD model is fitted to experimental data. The model was published in [1] and the dataset used for fitting exercise was published in [2].

2. **Nonlinear mixed effects -** an example where 1- and 2-compartment models are fitted against the Phenobarbital dataset described in [3] with different covariate expressions using SAEM.

<br />
<br />
<br />


### References

[1] Ayyar, V. S., Song, D., Zheng, S., Carpenter, T., & Heald, D. L. (2021). Minimal Physiologically Based Pharmacokinetic-Pharmacodynamic (mPBPK-PD) Model of N-Acetylgalactosamine-Conjugated Small Interfering RNA Disposition and Gene Silencing in Preclinical Species and Humans. The Journal of pharmacology and experimental therapeutics, 379(2), 134–146

[2] Habtemariam, B. A., Karsten, V., Attarwala, H., Goel, V., Melch, M., Clausen, V. A., Garg, P., Vaishnaw, A. K., Sweetser, M. T., Robbie, G. J., & Vest, J. (2021). Single-Dose Pharmacokinetics and Pharmacodynamics of Transthyretin Targeting N-acetylgalactosamine-Small Interfering Ribonucleic Acid Conjugate, Vutrisiran, in Healthy Subjects. Clinical pharmacology and therapeutics, 109(2), 372–382

[3] Grasela TH Jr, Donn SM. Neonatal population pharmacokinetics of phenobarbital derived from routine clinical data. Dev Pharmacol Ther 1985:8(6). 374-83.