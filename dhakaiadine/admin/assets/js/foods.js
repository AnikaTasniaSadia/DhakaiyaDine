import { supabase } from '../../supabase/config.js';

let dataTable;

document.addEventListener('DOMContentLoaded', async () => {
    // 1. Initialize DataTable
    dataTable = $('#foodsTable').DataTable({
        responsive: true,
        order: [[1, 'asc']], // Sort by name
        columns: [
            { data: 'imageUrl', orderable: false, render: data => `<img src="${data || 'assets/images/placeholder.jpg'}" class="food-image">` },
            { data: 'name' },
            { data: 'category' },
            { data: 'price', render: data => `$${data.toFixed(2)}` },
            { data: 'discountedPrice', render: data => data ? `$${data.toFixed(2)}` : '-' },
            { data: 'deliveryTime' },
            { 
                data: 'id',
                orderable: false,
                render: function(data, type, row) {
                    // Store full row data in data attributes to easily pass to edit function
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

    // 2. Fetch Data
    await loadFoods();

    // 3. Realtime Listener
    supabase
        .channel('public:foods')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'foods' }, payload => {
            console.log('Realtime update:', payload);
            loadFoods(); // Reload table on any change
        })
        .subscribe();

    // 4. Form Submit Handler (Add/Edit)
    document.getElementById('foodForm').addEventListener('submit', handleFormSubmit);

    // 5. Setup Action Buttons (Event Delegation)
    $('#foodsTable tbody').on('click', '.edit-btn', function() {
        const id = $(this).data('id');
        const rowData = dataTable.row($(this).parents('tr')).data();
        openEditModal(rowData);
    });

    $('#foodsTable tbody').on('click', '.delete-btn', function() {
        const id = $(this).data('id');
        deleteFood(id);
    });

    // Reset form on "Add New Food" click
    document.getElementById('btnAddFood').addEventListener('click', () => {
        document.getElementById('foodForm').reset();
        document.getElementById('foodId').value = '';
        document.getElementById('existingImageUrl').value = '';
        document.getElementById('imagePreviewContainer').classList.add('d-none');
        document.getElementById('foodModalLabel').textContent = 'Add Food';
    });
});

async function loadFoods() {
    try {
        const { data, error } = await supabase.from('foods').select('*').order('name');
        if (error) throw error;
        
        dataTable.clear();
        dataTable.rows.add(data);
        dataTable.draw();
    } catch (error) {
        Swal.fire('Error', 'Failed to load foods: ' + error.message, 'error');
    }
}

async function handleFormSubmit(e) {
    e.preventDefault();
    const btnSave = document.getElementById('btnSaveFood');
    btnSave.disabled = true;
    btnSave.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Saving...';

    try {
        const id = document.getElementById('foodId').value;
        const name = document.getElementById('foodName').value;
        const category = document.getElementById('foodCategory').value;
        const price = parseFloat(document.getElementById('foodPrice').value);
        const discountedPriceStr = document.getElementById('foodDiscountPrice').value;
        const discountedPrice = discountedPriceStr ? parseFloat(discountedPriceStr) : null;
        const deliveryTime = document.getElementById('foodDelivery').value || '';
        const description = document.getElementById('foodDescription').value || '';
        const imageFile = document.getElementById('foodImage').files[0];
        let imageUrl = document.getElementById('existingImageUrl').value;

        // Image Upload Logic
        if (imageFile) {
            imageUrl = await compressAndUploadImage(imageFile);
        }

        const payload = {
            name,
            category,
            price,
            discountedPrice,
            deliveryTime,
            description,
            imageUrl,
            rating: 0 // Default rating
        };

        if (id) {
            // Edit
            const { error } = await supabase.from('foods').update(payload).eq('id', id);
            if (error) throw error;
            Swal.fire('Updated!', 'Food has been updated.', 'success');
        } else {
            // Add
            payload.id = window.generateUUID();
            const { error } = await supabase.from('foods').insert([payload]);
            if (error) throw error;
            Swal.fire('Added!', 'New food has been added.', 'success');
        }

        bootstrap.Modal.getInstance(document.getElementById('foodModal')).hide();
        loadFoods();
    } catch (error) {
        Swal.fire('Error', error.message, 'error');
    } finally {
        btnSave.disabled = false;
        btnSave.textContent = 'Save Food';
    }
}

function openEditModal(food) {
    document.getElementById('foodId').value = food.id;
    document.getElementById('foodName').value = food.name;
    document.getElementById('foodCategory').value = food.category;
    document.getElementById('foodPrice').value = food.price;
    document.getElementById('foodDiscountPrice').value = food.discountedPrice || '';
    document.getElementById('foodDelivery').value = food.deliveryTime || '';
    document.getElementById('foodDescription').value = food.description || '';
    document.getElementById('existingImageUrl').value = food.imageUrl || '';
    document.getElementById('foodModalLabel').textContent = 'Edit Food';

    if (food.imageUrl) {
        document.getElementById('imagePreviewContainer').classList.remove('d-none');
        document.getElementById('imagePreview').src = food.imageUrl;
    } else {
        document.getElementById('imagePreviewContainer').classList.add('d-none');
    }

    new bootstrap.Modal(document.getElementById('foodModal')).show();
}

async function deleteFood(id) {
    const result = await Swal.fire({
        title: 'Are you sure?',
        text: "You won't be able to revert this!",
        icon: 'warning',
        showCancelButton: true,
        background: '#1e1e1e',
        color: '#fff',
        confirmButtonColor: '#e74c3c',
        cancelButtonColor: '#333',
        confirmButtonText: 'Yes, delete it!'
    });

    if (result.isConfirmed) {
        try {
            const { error } = await supabase.from('foods').delete().eq('id', id);
            if (error) throw error;
            Swal.fire('Deleted!', 'Food has been deleted.', 'success');
            loadFoods();
        } catch (error) {
            Swal.fire('Error', 'Failed to delete: ' + error.message, 'error');
        }
    }
}

async function compressAndUploadImage(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = event => {
            const img = new Image();
            img.src = event.target.result;
            img.onload = async () => {
                const canvas = document.createElement('canvas');
                const MAX_WIDTH = 800;
                const MAX_HEIGHT = 800;
                let width = img.width;
                let height = img.height;

                if (width > height) {
                    if (width > MAX_WIDTH) {
                        height *= MAX_WIDTH / width;
                        width = MAX_WIDTH;
                    }
                } else {
                    if (height > MAX_HEIGHT) {
                        width *= MAX_HEIGHT / height;
                        height = MAX_HEIGHT;
                    }
                }

                canvas.width = width;
                canvas.height = height;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, width, height);

                canvas.toBlob(async (blob) => {
                    const fileName = `foods/${Date.now()}_${file.name.replace(/\s+/g, '_')}`;
                    try {
                        const { data, error } = await supabase.storage
                            .from('images')
                            .upload(fileName, blob, { contentType: 'image/jpeg' });
                        
                        if (error) throw error;
                        
                        const { data: publicUrlData } = supabase.storage
                            .from('images')
                            .getPublicUrl(fileName);
                            
                        resolve(publicUrlData.publicUrl);
                    } catch (err) {
                        reject(err);
                    }
                }, 'image/jpeg', 0.8);
            };
        };
        reader.onerror = error => reject(error);
    });
}
