import { supabase } from '../../supabase/config.js';

let banners = [];

document.addEventListener('DOMContentLoaded', async () => {
    await loadBanners();

    // Setup Realtime
    supabase
        .channel('public:banners')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'banners' }, payload => {
            loadBanners();
        })
        .subscribe();

    document.getElementById('bannerForm').addEventListener('submit', handleFormSubmit);

    document.getElementById('btnAddBanner').addEventListener('click', () => {
        document.getElementById('bannerForm').reset();
        document.getElementById('bannerId').value = '';
        document.getElementById('existingImageUrl').value = '';
        document.getElementById('imagePreviewContainer').classList.add('d-none');
        document.getElementById('bannerModalLabel').textContent = 'Add Banner';
        document.getElementById('bannerEnabled').checked = true;
    });
});

async function loadBanners() {
    try {
        const { data, error } = await supabase.from('banners').select('*');
        if (error) {
            if(error.code === '42P01') {
                console.warn("Banners table doesn't exist yet.");
                document.getElementById('bannersList').innerHTML = `<div class="col-12"><div class="alert alert-warning">Banners table does not exist. Please create it in Supabase. (id, image_url, title, active)</div></div>`;
                return;
            }
            throw error;
        }
        
        banners = data || [];
        renderBanners();
    } catch (error) {
        console.error(error);
    }
}

function renderBanners() {
    const list = document.getElementById('bannersList');
    list.innerHTML = '';
    
    if(banners.length === 0) {
        list.innerHTML = `<div class="col-12 text-center text-secondary py-5">No banners found.</div>`;
        return;
    }

    banners.forEach(b => {
        const isEnabled = b.active !== false;
        const col = document.createElement('div');
        col.className = 'col-12 col-md-6 col-lg-4';
        col.innerHTML = `
            <div class="card bg-card border-secondary h-100 position-relative ${isEnabled ? '' : 'opacity-50'}">
                <img src="${b.image_url || 'assets/images/placeholder.jpg'}" class="card-img-top" style="height: 150px; object-fit: cover;" alt="Banner">
                <div class="card-body">
                    <h5 class="card-title text-gold">${b.title || 'No Title'}</h5>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="badge ${isEnabled ? 'bg-success' : 'bg-secondary'}">${isEnabled ? 'Active' : 'Disabled'}</span>
                    </div>
                </div>
                <div class="card-footer bg-transparent border-secondary d-flex justify-content-end gap-2">
                    <button class="btn btn-sm btn-outline-warning" onclick="editBanner('${b.id}')"><i class="fas fa-edit"></i> Edit</button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteBanner('${b.id}')"><i class="fas fa-trash"></i> Delete</button>
                </div>
            </div>
        `;
        list.appendChild(col);
    });
}

window.editBanner = function(id) {
    const b = banners.find(x => x.id === id);
    if(!b) return;

    document.getElementById('bannerId').value = b.id;
    document.getElementById('bannerOfferText').value = b.title || '';
    document.getElementById('bannerEnabled').checked = b.active !== false;
    document.getElementById('existingImageUrl').value = b.image_url || '';
    document.getElementById('bannerModalLabel').textContent = 'Edit Banner';

    if (b.image_url) {
        document.getElementById('imagePreviewContainer').classList.remove('d-none');
        document.getElementById('imagePreview').src = b.image_url;
    } else {
        document.getElementById('imagePreviewContainer').classList.add('d-none');
    }

    new bootstrap.Modal(document.getElementById('bannerModal')).show();
}

window.deleteBanner = async function(id) {
    const result = await Swal.fire({
        title: 'Delete Banner?',
        icon: 'warning',
        showCancelButton: true,
        background: '#1e1e1e',
        color: '#fff',
        confirmButtonColor: '#e74c3c'
    });

    if (result.isConfirmed) {
        try {
            const { error } = await supabase.from('banners').delete().eq('id', id);
            if (error) throw error;
            loadBanners();
        } catch (error) {
            Swal.fire('Error', error.message, 'error');
        }
    }
}

async function handleFormSubmit(e) {
    e.preventDefault();
    const btnSave = document.getElementById('btnSaveBanner');
    btnSave.disabled = true;
    btnSave.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Saving...';

    try {
        const id = document.getElementById('bannerId').value;
        const imageFile = document.getElementById('bannerImage').files[0];
        let imageUrl = document.getElementById('existingImageUrl').value;

        if (!imageUrl && !imageFile) {
            throw new Error("Image is required for banners.");
        }

        if (imageFile) {
            imageUrl = await compressAndUploadImage(imageFile);
        }

        const payload = {
            image_url: imageUrl,
            title: document.getElementById('bannerOfferText').value,
            active: document.getElementById('bannerEnabled').checked
        };

        if (id) {
            const { error } = await supabase.from('banners').update(payload).eq('id', id);
            if (error) throw error;
        } else {
            payload.id = window.generateUUID();
            const { error } = await supabase.from('banners').insert([payload]);
            if (error) throw error;
        }

        bootstrap.Modal.getInstance(document.getElementById('bannerModal')).hide();
        loadBanners();
        Swal.fire('Success', 'Banner saved!', 'success');
    } catch (error) {
        if(error.code === '42P01') {
            Swal.fire('Error', 'The "banners" table does not exist in your Supabase database.', 'error');
        } else {
            Swal.fire('Error', error.message, 'error');
        }
    } finally {
        btnSave.disabled = false;
        btnSave.textContent = 'Save Banner';
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
                const MAX_WIDTH = 1200; // Banners can be wider
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
                    const fileName = `banners/${Date.now()}_${file.name.replace(/\s+/g, '_')}`;
                    try {
                        const { data, error } = await supabase.storage
                            .from('banners')
                            .upload(fileName, blob, { contentType: 'image/jpeg' });
                        
                        if (error) throw error;
                        
                        const { data: publicUrlData } = supabase.storage
                            .from('banners')
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
