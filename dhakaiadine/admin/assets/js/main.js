import { supabase } from '../../supabase/config.js';

// Setup global UUID fallback for HTTP access on local network
window.generateUUID = function() {
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
        return crypto.randomUUID();
    }
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
};

document.addEventListener('DOMContentLoaded', async () => {
    // 1. Session Check (Protect Page)
    const isStaticAdmin = localStorage.getItem('static_admin') === 'true';
    let sessionUser = null;

    if (!isStaticAdmin) {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session) {
            window.location.replace('login.html');
            return;
        }
        sessionUser = session.user;
    }

    // Display user email (optional, if element exists)
    const userEmailElement = document.getElementById('userEmail');
    if (userEmailElement) {
        userEmailElement.textContent = isStaticAdmin ? 'admin@gmail.com' : sessionUser.email;
    }

    // 2. Sidebar Toggle
    const sidebarCollapse = document.getElementById('sidebarCollapse');
    const sidebar = document.getElementById('sidebar');
    const content = document.getElementById('content');

    if (sidebarCollapse) {
        sidebarCollapse.addEventListener('click', () => {
            sidebar.classList.toggle('active');
            content.classList.toggle('active');
        });
    }

    // 3. Logout
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            
            Swal.fire({
                title: 'Are you sure?',
                text: "You will be logged out of the admin panel.",
                icon: 'warning',
                showCancelButton: true,
                background: '#1e1e1e',
                color: '#fff',
                confirmButtonColor: '#d4af37',
                cancelButtonColor: '#e74c3c',
                confirmButtonText: 'Yes, logout'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    if (localStorage.getItem('static_admin') === 'true') {
                        localStorage.removeItem('static_admin');
                    } else {
                        await supabase.auth.signOut();
                    }
                    window.location.replace('login.html');
                }
            });
        });
    }
});
