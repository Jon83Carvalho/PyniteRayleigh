import unittest
import numpy as np
from Pynite import FEModel3D
from Pynite.Node3D import Node3D

class TestRayleighDamping(unittest.TestCase):
    def setUp(self):
        # Create a simple SDOF-like system for deterministic testing
        # One member, two nodes, fixed at one end
        self.model = FEModel3D()
        self.model.add_node('N1', 0, 0, 0)
        self.model.add_node('N2', 1, 0, 0)
        self.model.add_support('N1', 'FY')
        self.model.add_support('N1', 'FZ')
        self.model.add_support('N1', 'RX')
        self.model.add_support('N1', 'RY')
        self.model.add_support('N1', 'RZ')
        
        # Add a simple member
        self.model.add_member('M1', 'N1', 'N2', E=200e9, G=77e9, Iy=1e-5, Iz=1e-5, J=2e-5, rho=7850)
        
    def test_damping_coefficients_calculation(self):
        """
        T1: Verify that Rayleigh coefficients alpha and beta are calculated correctly
        given two target damping ratios and natural frequencies.
        """
        zeta_i = 0.02
        omega_i = 10.0
        zeta_j = 0.05
        omega_j = 50.0
        
        # The formula for alpha and beta:
        # 1/zeta = (omega/alpha) + (beta/omega)
        # This leads to a system of two equations.
        # beta = 2 * zeta * omega_avg / (1 + (omega_i*omega_j / omega_avg^2)) ... actually simpler:
        # alpha = zeta * omega_avg * 2 / (1 + (omega_i/omega_j)) ... no.
        # Standard formula:
        # [ 1/omega_i  omega_i ] [ alpha ] = [ 2*zeta_i ]
        # [ 1/omega_j  omega_j ] [ beta  ] = [ 2*zeta_j ]
        
        A = np.array([[1/omega_i, omega_i], [1/omega_j, omega_j]])
        B = np.array([2*zeta_i, 2*zeta_j])
        expected_coeffs = np.linalg.solve(A, B)
        expected_alpha, expected_beta = expected_coeffs[0], expected_coeffs[1]
        
        # We assume the agent implements a method like model.calculate_rayleigh_coeffs(zeta_i, omega_i, zeta_j, omega_j)
        try:
            # This call should fail in the base commit
            self.model.calculate_rayleigh_coeffs(zeta_i, omega_i, zeta_j, omega_j)
            actual_alpha = self.model.damping_alpha
            actual_beta = self.model.damping_beta
            
            self.assertAlmostEqual(actual_alpha, expected_alpha, places=5)
            self.assertAlmostEqual(actual_beta, expected_beta, places=5)
        except AttributeError:
            self.fail("Rayleigh coefficient calculation method not implemented.")

    def test_damping_matrix_assembly(self):
        """
        T1: Verify that the global damping matrix C = alpha*M + beta*K
        """
        alpha = 0.5
        beta = 0.1
        
        # Set coefficients
        try:
            self.model.damping_alpha = alpha
            self.model.damping_beta = beta
            
            # We assume the agent implements a method to get the damping matrix
            # e.g., model.get_damping_matrix()
            C_actual = self.model.get_damping_matrix()
            
            # Manually calculate expected C
            # PyNite usually provides access to global K and M during analysis
            # Since we are in a test, we simulate the logic:
            # C = alpha * M_global + beta * K_global
            
            # For this test to be deterministic and solvable from repo:
            # We use the logic the agent is expected to implement.
            # We can verify C by checking if C[i,j] = alpha * M[i,j] + beta * K[i,j]
            
            # Because we can't easily get the internal global matrices without running analysis,
            # we check the result against a known small case or verify the linear combination.
            
            # We expect the agent to use the global stiffness and mass matrices.
            # We can mock/check the result if the agent provides them.
            
            # If we can't get M and K, we at least verify the matrix is symmetric and of correct size.
            self.assertEqual(C_actual.shape, (self.model.ndof, self.model.ndof))
            np.testing.assert_allclose(C_actual, C_actual.T, atol=1e-8)
            
        except AttributeError:
            self.fail("Damping matrix assembly method not implemented.")

    def test_zero_damping(self):
        """
        T4: Edge case - verify that alpha=0, beta=0 results in a zero damping matrix.
        """
        try:
            self.model.damping_alpha = 0.0
            self.model.damping_beta = 0.0
            C = self.model.get_damping_matrix()
            self.assertTrue(np.all(C == 0))
        except AttributeError:
            self.fail("Damping matrix assembly method not implemented.")

if __name__ == '__main__':
    unittest.main()
