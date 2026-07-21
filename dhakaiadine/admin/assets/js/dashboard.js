import { supabase } from '../../supabase/config.js';

document.addEventListener('DOMContentLoaded', async () => {
    // Set Current Date
    const dateOptions = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById('currentDate').textContent = new Date().toLocaleDateString('en-US', dateOptions);

    try {
        // 1. Fetch Today's Orders and Revenue
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayIso = today.toISOString();

        const { data: todayOrdersData, error: ordersError } = await supabase
            .from('orders')
            .select('id, total_amount')
            .gte('created_at', todayIso);

        if (ordersError) throw ordersError;

        const todayOrdersCount = todayOrdersData.length;
        const todayRevenue = todayOrdersData.reduce((sum, order) => sum + (order.total_amount || 0), 0);

        document.getElementById('todayOrders').textContent = todayOrdersCount;
        document.getElementById('todayRevenue').textContent = `$${todayRevenue.toFixed(2)}`;

        // 2. Fetch Total Customers
        // Assuming role 'customer' exists or users who are not admin
        const { count: customersCount, error: customersError } = await supabase
            .from('users')
            .select('*', { count: 'exact', head: true }); // Getting all users for now, can be filtered by role

        if (!customersError) {
            document.getElementById('totalCustomers').textContent = customersCount || 0;
        }

        // 3. Fetch Available Tables
        const { count: availableTablesCount, error: tablesError } = await supabase
            .from('tables')
            .select('*', { count: 'exact', head: true })
            .eq('status', 'available');

        if (!tablesError) {
            document.getElementById('availableTables').textContent = availableTablesCount || 0;
        }

        // 4. Setup Charts (Mock Data for now, can be replaced with real grouped queries)
        setupCharts();

    } catch (error) {
        console.error('Error loading dashboard data:', error);
    }
});

function setupCharts() {
    // Colors based on theme
    const goldPrimary = '#d4af37';
    const bgInput = '#2d2d2d';
    const textSecondary = '#a0a0a0';

    // Revenue Chart
    const ctxRevenue = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctxRevenue, {
        type: 'line',
        data: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
                label: 'Revenue ($)',
                data: [150, 230, 180, 320, 450, 500, 380], // Mock data
                borderColor: goldPrimary,
                backgroundColor: 'rgba(212, 175, 55, 0.1)',
                borderWidth: 2,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: {
                    grid: { color: bgInput },
                    ticks: { color: textSecondary }
                },
                y: {
                    grid: { color: bgInput },
                    ticks: { color: textSecondary }
                }
            }
        }
    });

    // Order Status Chart
    const ctxStatus = document.getElementById('orderStatusChart').getContext('2d');
    new Chart(ctxStatus, {
        type: 'doughnut',
        data: {
            labels: ['Pending', 'Preparing', 'Ready', 'Completed'],
            datasets: [{
                data: [12, 19, 3, 25], // Mock data
                backgroundColor: [
                    '#e74c3c', // danger for pending
                    '#f39c12', // warning for preparing
                    '#3498db', // info for ready
                    '#2ecc71'  // success for completed
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            cutout: '70%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: textSecondary }
                }
            }
        }
    });
}
