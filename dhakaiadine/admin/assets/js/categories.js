import { supabase } from '../../supabase/config.js';

let dataTable;

document.addEventListener('DOMContentLoaded', async () => {
    dataTable = $('#categoriesTable').DataTable({
        responsive: true,
        order: [[1, 'asc']],
        columns: [
            { data: 'name' },
            { data: 'sort_order' },
            { 
                data: 'status',
                render: data => data === 'active' ? `<span class="badge bg-success">Active</span>` : `<span class="badge bg-secondary">Hidden</span>`
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

    await loadCategories();

    // Setup Realtime
    supabase
        .channel('public:categories')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'categories' }, payload => {
            loadCategories();
        })
        .subscribe();

    document.getElementById('categoryForm').addEventListener('submit', handleFormSubmit);

    $('#categoriesTable tbody').on('click', '.edit-btn', function() {
        const rowData = dataTable.row($(this).parents('tr')).data();
        openEditModal(rowData);
    });

    $('#categoriesTable tbody').on('click', '.delete-btn', function() {
        deleteCategory($(this).data('id'));
    });

    document.getElementById('btnAddCategory').addEventListener('click', () => {
        document.getElementById('categoryForm').reset();
        document.getElementById('categoryId').value = '';
        document.getElementById('categoryModalLabel').textContent = 'Add Category';
    });
});

async function loadCategories() {
    try {
        const { data, error } = await supabase.from('categories').select('*').order('sort_order');
        if (error) {
            // Silently ignore if table doesn't exist, as warned in UI
            if(error.code === '42P01') {
                console.warn("Categories table doesn't exist yet.");
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
    const btnSave = document.getElementById('btnSaveCategory');
    btnSave.disabled = true;

    try {
        const id = document.getElementById('categoryId').value;
        const payload = {
            name: document.getElementById('categoryName').value,
            sort_order: parseInt(document.getElementById('categorySort').value) || 0,
            status: document.getElementById('categoryStatus').value
        };

        if (id) {
            const { error } = await supabase.from('categories').update(payload).eq('id', id);
            if (error) throw error;
        } else {
            payload.id = window.generateUUID();
            const { error } = await supabase.from('categories').insert([payload]);
            if (error) throw error;
        }

        bootstrap.Modal.getInstance(document.getElementById('categoryModal')).hide();
        loadCategories();
        Swal.fire('Success', 'Category saved!', 'success');
    } catch (error) {
        if(error.code === '42P01') {
            Swal.fire('Error', 'The "categories" table does not exist in your Supabase database. Please create it first.', 'error');
        } else {
            Swal.fire('Error', error.message, 'error');
        }
    } finally {
        btnSave.disabled = false;
    }
}

function openEditModal(cat) {
    document.getElementById('categoryId').value = cat.id;
    document.getElementById('categoryName').value = cat.name;
    document.getElementById('categorySort').value = cat.sort_order;
    document.getElementById('categoryStatus').value = cat.status;
    document.getElementById('categoryModalLabel').textContent = 'Edit Category';
    new bootstrap.Modal(document.getElementById('categoryModal')).show();
}

async function deleteCategory(id) {
    const result = await Swal.fire({
        title: 'Delete Category?',
        icon: 'warning',
        showCancelButton: true,
        background: '#1e1e1e',
        color: '#fff',
        confirmButtonColor: '#e74c3c'
    });

    if (result.isConfirmed) {
        try {
            const { error } = await supabase.from('categories').delete().eq('id', id);
            if (error) throw error;
            loadCategories();
        } catch (error) {
            Swal.fire('Error', error.message, 'error');
        }
    }
}
