import { supabase } from '../../supabase/config.js';

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const loginBtn = document.getElementById('loginBtn');
            const loginText = document.getElementById('loginText');
            const loginSpinner = document.getElementById('loginSpinner');

            // Show loading state
            loginBtn.disabled = true;
            loginText.classList.add('d-none');
            loginSpinner.classList.remove('d-none');

            try {
                // Static credential check
                if (email === 'admin@gmail.com' && password === 'admin123') {
                    localStorage.setItem('static_admin', 'true');
                    Swal.fire({
                        title: 'Welcome Back!',
                        text: 'Logged in as static admin.',
                        icon: 'success',
                        timer: 1500,
                        showConfirmButton: false,
                        background: '#1e1e1e',
                        color: '#fff',
                        iconColor: '#d4af37'
                    }).then(() => {
                        window.location.href = 'dashboard.html';
                    });
                    return; // Exit here for static login
                }

                // 1. Authenticate with Supabase
                const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
                    email,
                    password
                });

                if (authError) throw authError;

                // 2. Check User Role
                const userId = authData.user.id;
                const { data: userData, error: roleError } = await supabase
                    .from('users')
                    .select('role')
                    .eq('id', userId)
                    .single();

                if (roleError) throw roleError;

                const role = userData?.role?.toLowerCase();
                const adminRoles = ['admin', 'manager', 'kitchen', 'counter'];

                if (!adminRoles.includes(role)) {
                    // Sign out if not an admin
                    await supabase.auth.signOut();
                    throw new Error('Access denied. Admin privileges required.');
                }

                // 3. Success -> Redirect to dashboard
                Swal.fire({
                    title: 'Welcome Back!',
                    text: 'Login successful.',
                    icon: 'success',
                    timer: 1500,
                    showConfirmButton: false,
                    background: '#1e1e1e',
                    color: '#fff',
                    iconColor: '#d4af37'
                }).then(() => {
                    window.location.href = 'dashboard.html';
                });

            } catch (error) {
                // Handle errors
                Swal.fire({
                    title: 'Login Failed',
                    text: error.message || 'Invalid email or password.',
                    icon: 'error',
                    background: '#1e1e1e',
                    color: '#fff',
                    confirmButtonColor: '#d4af37'
                });
            } finally {
                // Restore button state
                loginBtn.disabled = false;
                loginText.classList.remove('d-none');
                loginSpinner.classList.add('d-none');
            }
        });
    }
});
