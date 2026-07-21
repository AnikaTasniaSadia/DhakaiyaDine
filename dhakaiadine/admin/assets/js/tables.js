import { supabase } from '../../supabase/config.js';

let dataTable;

document.addEventListener('DOMContentLoaded', async () => {
    dataTable = $('#restaurantTablesTable').DataTable({
        responsive: true,
        order: [[0, 'asc']],
        columns: [
            { data: 'name' },
            { data: 'branch_id', render: data => data || '-' },
            { data: 'capacity' },
            { data: 'floor', render: data => data || '-' },
            { 
                data: 'status',
                render: function(data) {
                    const statusColors = {
                        'available': 'success',
                        'reserved': 'warning text-dark',
                        'occupied': 'danger',
                        'cleaning': 'info text-dark',
                        'disabled': 'secondary'
                    };
                    const color = statusColors[data?.toLowerCase()] || 'secondary';
                    return `<span class="badge bg-${color}">${(data || 'unknown').toUpperCase()}</span>`;
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

    await loadTables();

    // Setup Realtime
    supabase
        .channel('public:tables')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'tables' }, payload => {
            loadTables();
        })
        .subscribe();

    document.getElementById('tableForm').addEventListener('submit', handleFormSubmit);

    $('#restaurantTablesTable tbody').on('click', '.edit-btn', function() {
        const rowData = dataTable.row($(this).parents('tr')).data();
        openEditModal(rowData);
    });

    $('#restaurantTablesTable tbody').on('click', '.delete-btn', function() {
        deleteTable($(this).data('id'));
    });

    document.getElementById('btnAddTable').addEventListener('click', () => {
        document.getElementById('tableForm').reset();
        document.getElementById('tableId').value = '';
        document.getElementById('tableModalLabel').textContent = 'Add Table';
    });
});

async function loadTables() {
    try {
        const { data, error } = await supabase.from('tables').select('*').order('name');
        if (error) {
            if(error.code === '42P01') {
                console.warn("Tables table doesn't exist.");
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
    const btnSave = document.getElementById('btnSaveTable');
    btnSave.disabled = true;

    try {
        const id = document.getElementById('tableId').value;
        const payload = {
            name: document.getElementById('tableName').value,
            branch_id: document.getElementById('tableBranch').value || null,
            capacity: parseInt(document.getElementById('tableCapacity').value) || 4,
            floor: document.getElementById('tableFloor').value,
            status: document.getElementById('tableStatus').value
        };

        if (id) {
            const { error } = await supabase.from('tables').update(payload).eq('id', id);
            if (error) throw error;
        } else {
            payload.id = window.generateUUID();
            const { error } = await supabase.from('tables').insert([payload]);
            if (error) throw error;
        }

        bootstrap.Modal.getInstance(document.getElementById('tableModal')).hide();
        loadTables();
        Swal.fire('Success', 'Table saved!', 'success');
    } catch (error) {
        if(error.code === '42P01') {
            Swal.fire('Error', 'The "tables" table does not exist in your Supabase database.', 'error');
        } else {
            Swal.fire('Error', error.message, 'error');
        }
    } finally {
        btnSave.disabled = false;
    }
}

function openEditModal(tableData) {
    document.getElementById('tableId').value = tableData.id;
    document.getElementById('tableName').value = tableData.name || '';
    document.getElementById('tableBranch').value = tableData.branch_id || '';
    document.getElementById('tableCapacity').value = tableData.capacity || 4;
    document.getElementById('tableFloor').value = tableData.floor || '';
    document.getElementById('tableStatus').value = tableData.status || 'available';
    document.getElementById('tableModalLabel').textContent = 'Edit Table';
    new bootstrap.Modal(document.getElementById('tableModal')).show();
}

async function deleteTable(id) {
    const result = await Swal.fire({
        title: 'Delete Table?',
        icon: 'warning',
        showCancelButton: true,
        background: '#1e1e1e',
        color: '#fff',
        confirmButtonColor: '#e74c3c'
    });

    if (result.isConfirmed) {
        try {
            const { error } = await supabase.from('tables').delete().eq('id', id);
            if (error) throw error;
            loadTables();
        } catch (error) {
            Swal.fire('Error', error.message, 'error');
        }
    }
}
