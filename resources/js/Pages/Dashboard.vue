<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, useForm, usePage } from '@inertiajs/vue3';

// Define props passed from the TaskController@dashboard
defineProps({
    tasks: Array,
});

// useForm helper for updating task status (for regular users)
const form = useForm({
    status: '',
});

// Function to submit the status update
const updateTaskStatus = (task) => {
    form.status = task.status;
    form.patch(route('tasks.update', task.id), {
        preserveScroll: true, // Don't jump to top of page after update
    });
};

const page = usePage();
const isAdmin = page.props.auth.user.is_admin;

/**
 * Checks if a task's deadline is within the next 2 days and not already past.
 * @param {string|null} deadline - The deadline date string in 'YYYY-MM-DD' format.
 * @returns {boolean}
 */
function isDeadlineApproaching(deadline) {
    if (!deadline) return false;

    const deadlineDate = new Date(deadline);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const diffTime = deadlineDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return diffDays >= 0 && diffDays <= 2;
}

/**
 * NEW: Checks if a task's deadline has already passed.
 * @param {string|null} deadline - The deadline date string in 'YYYY-MM-DD' format.
 * @returns {boolean}
 */
function isDeadlinePast(deadline) {
    if (!deadline) return false;

    const deadlineDate = new Date(deadline);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // If the deadline was before today, it's past due.
    return deadlineDate < today;
}
</script>

<template>
    <Head title="Dashboard" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">Dashboard</h2>
        </template>

        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <!-- Flash message for success -->
                <div v-if="page.props.flash.message" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                    <span class="block sm:inline">{{ page.props.flash.message }}</span>
                </div>
                
                <!-- "Assign Task" button for admins -->
                <div v-if="isAdmin" class="mb-4">
                    <Link :href="route('tasks.create')" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                        Assign New Task
                    </Link>
                </div>

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 text-gray-900">
                        <h3 v-if="isAdmin" class="text-lg font-medium text-gray-900 mb-4">All Tasks</h3>
                        <h3 v-else class="text-lg font-medium text-gray-900 mb-4">Your Assigned Tasks</h3>

                        <div v-if="tasks.length > 0">
                            <div v-for="task in tasks" :key="task.id" class="p-4 mb-4 border rounded-lg">
                                <div class="flex justify-between items-center">
                                    <div>
                                        <div class="flex items-center gap-x-3">
                                            <h4 class="font-bold">{{ task.title }}</h4>
                                            
                                            <!-- Past Due Badge -->
                                            <span v-if="isDeadlinePast(task.deadline) && task.status !== 'Completed'" class="inline-flex items-center rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-800">
                                                Past Due
                                            </span>
                                            
                                            <!-- Approaching Deadline Badge -->
                                            <span v-if="!isDeadlinePast(task.deadline) && isDeadlineApproaching(task.deadline) && task.status !== 'Completed'" class="inline-flex items-center rounded-full bg-orange-100 px-2.5 py-0.5 text-xs font-medium text-orange-800">
                                                Deadline Approaching
                                            </span>
                                        </div>

                                        <p class="text-gray-600 mt-1">{{ task.description }}</p>
                                        <p class="text-sm text-gray-500">Deadline: {{ task.deadline ?? 'N/A' }}</p>
                                        <p v-if="isAdmin && task.user" class="text-sm font-semibold text-blue-700 mt-2">
                                            Assigned To: {{ task.user.name }}
                                        </p>
                                    </div>
                                    <div>
                                        <!-- Conditionally disable the dropdown for regular users -->
                                        <select
                                            v-if="!isAdmin"
                                            v-model="task.status"
                                            @change="updateTaskStatus(task)"
                                            :disabled="isDeadlinePast(task.deadline) && task.status !== 'Completed'"
                                            class="rounded-md shadow-sm border-gray-300 disabled:bg-gray-100 disabled:cursor-not-allowed"
                                        >
                                            <option value="Pending">Pending</option>
                                            <option value="In Progress">In Progress</option>
                                            <option value="Completed">Completed</option>
                                        </select>
                                        
                                        <!-- Status badge for admins -->
                                        <span v-if="isAdmin" class="inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset"
                                            :class="{ 'bg-yellow-50 text-yellow-800 ring-yellow-600/20': task.status === 'Pending',
                                                      'bg-blue-50 text-blue-800 ring-blue-600/20': task.status === 'In Progress',
                                                      'bg-green-50 text-green-800 ring-green-600/20': task.status === 'Completed' }">
                                            {{ task.status }}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div v-else>
                            <p v-if="isAdmin">There are no tasks in the system.</p>
                            <p v-else>You have no tasks assigned to you.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>