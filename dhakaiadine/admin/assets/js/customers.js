import { supabase } from '../../supabase/config.js';

let dataTable;

document.addEventListener('DOMContentLoaded', async () => {
    dataTable = $('#customersTable').DataTable({
        responsive: true,
        order: [[4, 'desc']], // sort by joined date
        columns: [
            { 
                data: 'id',
                render: data => `<span class="text-secondary small" title="${data}">${data.substring(0,8)}...</span>`
            },
            { data: 'full_name', render: data => data || 'Unknown' },
            { data: 'email', render: data => data || '-' },
            { 
                data: 'role',
                render: function(data) {
                    const role = (data || 'customer').toLowerCase();
                    const badge = role === 'admin' ? 'danger' : (role === 'manager' ? 'warning' : 'primary');
                    return `<span class="badge bg-${badge}">${role}</span>`;
                }
            },
            { 
                data: 'created_at',
                render: data => data ? new Date(data).toLocaleDateString() : '-'
            }
        ]
    });

    await loadCustomers();
});

async function loadCustomers() {
    try {
        const { data, error } = await supabase.from('users').select('*');
        if (error) {
            if(error.code === '42P01') {
                console.warn("Users table doesn't exist or isn't accessible.");
                return;
            }
            throw error;
        }
        
        dataTable.clear();
        if (data) dataTable.rows.add(data);
        dataTable.draw();
    } catch (error) {
        console.error(error);
        Swal.fire('Error', 'Could not load customers: ' + error.message, 'error');
    }
}
