import { supabase } from '../../supabase/config.js';

let dataTable;
const statusOptions = ['pending', 'accepted', 'preparing', 'cooking', 'ready', 'completed', 'cancelled'];

document.addEventListener('DOMContentLoaded', async () => {
    dataTable = $('#ordersTable').DataTable({
        responsive: true,
        order: [[1, 'desc']], // Sort by date descending
        columns: [
            { 
                data: 'id',
                render: data => `<span class="text-secondary small" title="${data}">${data.substring(0,8)}...</span>`
            },
            { 
                data: 'created_at',
                render: data => new Date(data).toLocaleString()
            },
            { 
                data: 'token_number',
                render: data => `<span class="text-secondary small">${data || '-'}</span>`
            },
            { 
                data: 'grand_total',
                render: data => `<span class="text-gold fw-bold">$${(data || 0).toFixed(2)}</span>`
            },
            { 
                data: 'status',
                render: function(data, type, row) {
                    let optionsHtml = '';
                    statusOptions.forEach(opt => {
                        const selected = (data && data.toLowerCase() === opt) ? 'selected' : '';
                        optionsHtml += `<option value="${opt}" ${selected}>${opt.charAt(0).toUpperCase() + opt.slice(1)}</option>`;
                    });
                    
                    const badgeClass = getStatusBadge(data);
                    
                    return `
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge bg-${badgeClass} d-none d-lg-inline-block" style="width: 80px;">${(data || 'unknown').toUpperCase()}</span>
                            <select class="status-dropdown" data-id="${row.id}">
                                ${optionsHtml}
                            </select>
                        </div>
                    `;
                }
            },
            { 
                data: 'id',
                orderable: false,
                render: function(data) {
                    return `
                        <button class="btn btn-sm btn-outline-info view-btn" data-id="${data}">
                            <i class="fas fa-eye"></i> Details
                        </button>
                    `;
                }
            }
        ]
    });

    await loadOrders();

    // Setup Realtime
    supabase
        .channel('public:orders')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'orders' }, payload => {
            console.log('Order updated!', payload);
            loadOrders();
        })
        .subscribe();

    // Handle Status Change
    $('#ordersTable tbody').on('change', '.status-dropdown', async function() {
        const id = $(this).data('id');
        const newStatus = $(this).val();
        $(this).prop('disabled', true); // disable while saving

        try {
            const { error } = await supabase.from('orders').update({ status: newStatus }).eq('id', id);
            if (error) throw error;
            // The realtime listener will refresh the table, but we can enable it just in case
            $(this).prop('disabled', false);
            
            // Show tiny toast
            const Toast = Swal.mixin({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 2000,
                timerProgressBar: true,
                background: '#1e1e1e',
                color: '#fff'
            });
            Toast.fire({ icon: 'success', title: 'Status Updated' });

        } catch (error) {
            Swal.fire('Error', error.message, 'error');
            $(this).prop('disabled', false);
            loadOrders(); // revert change
        }
    });

    // Handle View Details
    $('#ordersTable tbody').on('click', '.view-btn', function() {
        const id = $(this).data('id');
        const rowData = dataTable.row($(this).parents('tr')).data();
        openDetailsModal(rowData);
    });
});

function getStatusBadge(status) {
    status = status ? status.toLowerCase() : '';
    switch(status) {
        case 'pending': return 'warning text-dark';
        case 'accepted': return 'info text-dark';
        case 'preparing': 
        case 'cooking': return 'primary';
        case 'ready': return 'success';
        case 'completed': return 'secondary';
        case 'cancelled': return 'danger';
        default: return 'secondary';
    }
}

async function loadOrders() {
    try {
        const { data, error } = await supabase.from('orders').select('*').order('created_at', { ascending: false });
        if (error) {
            if(error.code === '42P01') {
                console.warn("Orders table doesn't exist.");
                return;
            }
            throw error;
        }
        
        dataTable.clear();
        if (data) dataTable.rows.add(data);
        dataTable.draw(false); // keep pagination
    } catch (error) {
        console.error(error);
    }
}

async function openDetailsModal(order) {
    document.getElementById('detailOrderId').textContent = order.id;
    document.getElementById('detailTotal').textContent = '$' + (order.grand_total || 0).toFixed(2);
    
    const tbody = document.getElementById('detailItemsBody');
    tbody.innerHTML = '<tr><td colspan="3" class="text-center"><span class="spinner-border spinner-border-sm text-gold"></span> Loading items...</td></tr>';
    
    new bootstrap.Modal(document.getElementById('orderDetailsModal')).show();

    try {
        const { data, error } = await supabase.from('order_items').select('*').eq('order_id', order.id);
        if (error) {
            if(error.code === '42P01') {
                tbody.innerHTML = '<tr><td colspan="3" class="text-center text-danger">order_items table not found</td></tr>';
                return;
            }
            throw error;
        }

        tbody.innerHTML = '';
        if(!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary">No items found for this order</td></tr>';
            return;
        }

        data.forEach(item => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><span class="small" title="${item.food_id}">${(item.food_id || 'unknown').substring(0,8)}...</span></td>
                <td>${item.quantity || 1}</td>
                <td class="text-gold">$${(item.price || 0).toFixed(2)}</td>
            `;
            tbody.appendChild(tr);
        });

    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="3" class="text-center text-danger">Error: ${error.message}</td></tr>`;
    }
}
