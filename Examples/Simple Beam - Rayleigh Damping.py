# Example of a simply supported beam with Rayleigh damping.
# This example demonstrates how to:
# 1. Set up a beam model
# 2. Perform modal analysis to get natural frequencies
# 3. Calculate Rayleigh damping coefficients
# 4. Assemble the global damping matrix
# Units used for the model in this example are inches and kips

# Import `FEModel3D` from `Pynite`
from Pynite import FEModel3D
import numpy as np

# Create a new finite element model
simple_beam = FEModel3D()

# Add nodes (14 ft apart)
simple_beam.add_node('N1', 0, 0, 0)
simple_beam.add_node('N2', 14*12, 0, 0)

# Define a material
E = 29000       # Modulus of elasticity (ksi)
G = 11200       # Shear modulus of elasticity (ksi)
nu = 0.3        # Poisson's ratio
rho = 2.836e-4  # Density (kci) - important for modal analysis
simple_beam.add_material('Steel', E, G, nu, rho)

# Add a section with the following properties:
# Iy = 100 in^4, Iz = 150 in^4, J = 250 in^4, A = 20 in^2
simple_beam.add_section('MySection', 20, 100, 150, 250)

# Add member
simple_beam.add_member('M1', 'N1', 'N2', 'Steel', 'MySection')

# Provide simple supports
simple_beam.def_support('N1', True, True, True, True, False, False)  # Constrained for torsion at 'N1'
simple_beam.def_support('N2', True, True, True, False, False, False) # Not constrained for torsion at 'N2'

# Add a downward point load of 5 kips at the midspan of the beam
simple_beam.add_member_pt_load('M1', 'Fy', -5, 7*12, 'D') # 5 kips Dead load
simple_beam.add_member_pt_load('M1', 'Fy', -8, 7*12, 'L') # 8 kips Live load

# Add load combinations
simple_beam.add_load_combo('1.4D', {'D':1.4})
simple_beam.add_load_combo('1.2D+1.6L', {'D':1.2, 'L':1.6})

# Perform static analysis
simple_beam.analyze(check_statics=True)

print('='*60)
print('STATIC ANALYSIS RESULTS')
print('='*60)

# Print reactions at each end of the beam
print('Left Support Reaction:', simple_beam.nodes['N1'].RxnFY['1.2D+1.6L'], 'kip')
print('Right Support Reaction:', simple_beam.nodes['N2'].RxnFY['1.2D+1.6L'], 'kip')

# Print the max/min shears and moments in the beam
print('Maximum Shear:', simple_beam.members['M1'].max_shear('Fy', '1.2D+1.6L'), 'kip')
print('Minimum Shear:', simple_beam.members['M1'].min_shear('Fy', '1.2D+1.6L'), 'kip')
print('Maximum Moment:', simple_beam.members['M1'].max_moment('Mz', '1.2D+1.6L')/12, 'kip-ft')
print('Minimum Moment:', simple_beam.members['M1'].min_moment('Mz', '1.2D+1.6L')/12, 'kip-ft')

# Print the max/min deflections in the beam
print('Maximum Deflection:', simple_beam.members['M1'].max_deflection('dy', '1.2D+1.6L'), 'in')
print('Minimum Deflection:', simple_beam.members['M1'].min_deflection('dy', '1.2D+1.6L'), 'in')

print('\n' + '='*60)
print('RAYLEIGH DAMPING ANALYSIS')
print('='*60)

# Perform modal analysis to get natural frequencies
# This is required for automatic Rayleigh coefficient calculation
simple_beam.analyze_modal(num_modes=6, log=True)

print('\nNatural Frequencies (Hz):')
for i, freq in enumerate(simple_beam.frequencies):
    print(f'  Mode {i+1}: {freq:.4f} Hz')

# Calculate Rayleigh damping coefficients
# Option 1: Automatic - uses Mode 1 and Mode 2 frequencies with default 2% damping
print('\nCalculating Rayleigh damping coefficients (automatic mode)...')
simple_beam.calculate_rayleigh_coeffs()

print(f'Alpha (mass-proportional): {simple_beam.damping_alpha:.6e}')
print(f'Beta (stiffness-proportional): {simple_beam.damping_beta:.6e}')

# Option 2: Manual - specify custom frequencies and damping ratios
# Uncomment the lines below to use manual specification
# print('\nCalculating Rayleigh damping coefficients (manual mode)...')
# omega_i = 2 * np.pi * simple_beam.frequencies[0]  # Mode 1 angular frequency
# omega_j = 2 * np.pi * simple_beam.frequencies[2]  # Mode 3 angular frequency
# simple_beam.calculate_rayleigh_coeffs(omega_i, omega_j, zeta_i=0.03, zeta_j=0.05)
# print(f'Alpha (mass-proportional): {simple_beam.damping_alpha:.6e}')
# print(f'Beta (stiffness-proportional): {simple_beam.damping_beta:.6e}')

# Get the global damping matrix
print('\nAssembling global damping matrix...')
C = simple_beam.get_damping_matrix()

print(f'Damping matrix shape: {C.shape}')
print(f'Damping matrix type: {type(C).__name__}')
print(f'Non-zero elements: {C.nnz if hasattr(C, "nnz") else np.count_nonzero(C)}')

# Verify damping matrix properties
print('\nDamping matrix properties:')
print(f'  Symmetric: {np.allclose(C.toarray() if hasattr(C, "toarray") else C, 
                                   (C.toarray() if hasattr(C, "toarray") else C).T, atol=1e-10)}')
print(f'  Maximum value: {np.max(C.toarray() if hasattr(C, "toarray") else C):.6e}')
print(f'  Minimum value: {np.min(C.toarray() if hasattr(C, "toarray") else C):.6e}')

print('\n' + '='*60)
print('Rayleigh damping matrix successfully assembled!')
print('='*60)
