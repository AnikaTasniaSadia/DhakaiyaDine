import { supabase } from '../../supabase/config.js';

let dataTable;

document.addEventListener('DOMContentLoaded', async () => {
    dataTable = $('#branchesTable').DataTable({
        responsive: true,
        order: [[0, 'asc']],
        columns: [
            { data: 'name' },
            { data: 'address' },
            { data: 'phone' },
            { 
                data: null,
                orderable: false,
                render: function(data, type, row) {
                    let tags = '';
                    if(row.delivery_available) tags += '<span class="badge bg-success me-1">Delivery</span>';
                    if(row.dine_in_available) tags += '<span class="badge bg-info">Dine In</span>';
                    return tags || '-';
                }
            },
            { 
                data: 'id',
                orderable: false,
                render: function(data) {
                    return `
                        <button class="btn btn-sm btn-outline-warning edit-btn" data-id="${data}">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger delete-btn" data-id="${data}">
                            <i class="fas fa-trash"></i>
                        </button>
                    `;
                }
            }
        ]
    });

    await loadBranches();

    // Setup Realtime
    supabase
        .channel('public:branches')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'branches' }, payload => {
            loadBranches();
        })
        .subscribe();

    document.getElementById('branchForm').addEventListener('submit', handleFormSubmit);

    $('#branchesTable tbody').on('click', '.edit-btn', function() {
        const rowData = dataTable.row($(this).parents('tr')).data();
        openEditModal(rowData);
    });

    $('#branchesTable tbody').on('click', '.delete-btn', function() {
        deleteBranch($(this).data('id'));
    });

    document.getElementById('btnAddBranch').addEventListener('click', () => {
        document.getElementById('branchForm').reset();
        document.getElementById('branchId').value = '';
        document.getElementById('branchModalLabel').textContent = 'Add Branch';
    });
});

async function loadBranches() {
    try {
        const { data, error } = await supabase.from('branches').select('*').order('name');
        if (error) {
            if(error.code === '42P01') {
                console.warn("Branches table doesn't exist.");
                return;
            }
            throw error;
        }
        
        dataTable.clear();
        if (data) dataTable.rows.add(data);
        dataTable.draw();
    } catch (error) {
        console.error(error);
    }
}

async function handleFormSubmit(e) {
    e.preventDefault();
    const btnSave = document.getElementById('btnSaveBranch');
    btnSave.disabled = true;

    try {
        const id = document.getElementById('branchId').value;
        const payload = {
            name: document.getElementById('branchName').value,
            address: document.getElementById('branchAddress').value,
            opening_hours: document.getElementById('branchHours').value
        };

        if (id) {
            const { error } = await supabase.from('branches').update(payload).eq('id', id);
            if (error) throw error;
        } else {
            payload.id = window.generateUUID();
            const { error } = await supabase.from('branches').insert([payload]);
            if (error) throw error;
        }

        bootstrap.Modal.getInstance(document.getElementById('branchModal')).hide();
        loadBranches();
        Swal.fire('Success', 'Branch saved!', 'success');
    } catch (error) {
        if(error.code === '42P01') {
            Swal.fire('Error', 'The "branches" table does not exist in your Supabase database.', 'error');
        } else {
            Swal.fire('Error', error.message, 'error');
        }
    } finally {
        btnSave.disabled = false;
    }
}

function openEditModal(branch) {
    document.getElementById('branchId').value = branch.id;
    document.getElementById('branchName').value = branch.name || '';
    document.getElementById('branchPhone').value = branch.phone || '';
    document.getElementById('branchAddress').value = branch.address || '';
    document.getElementById('branchEmail').value = branch.email || '';
    document.getElementById('branchHours').value = branch.opening_hours || '';
    document.getElementById('branchMap').value = branch.google_map || '';
    document.getElementById('branchDelivery').checked = branch.delivery_available;
    document.getElementById('branchDineIn').checked = branch.dine_in_available;
    document.getElementById('branchModalLabel').textContent = 'Edit Branch';
    new bootstrap.Modal(document.getElementById('branchModal')).show();
}

async function deleteBranch(id) {
    const result = await Swal.fire({
        title: 'Delete Branch?',
        text: "This action cannot be undone.",
        icon: 'warning',
        showCancelButton: true,
        background: '#1e1e1e',
        color: '#fff',
        confirmButtonColor: '#e74c3c'
    });

    if (result.isConfirmed) {
        try {
            const { error } = await supabase.from('branches').delete().eq('id', id);
            if (error) throw error;
            loadBranches();
        } catch (error) {
            Swal.fire('Error', error.message, 'error');
        }
    }
}
