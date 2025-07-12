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

const updateTaskStatus = (task) => {
    form.status = task.status;
    form.patch(route('tasks.update', task.id), {
        preserveScroll: true, // Don't jump to top of page after update
    });
};

const page = usePage();
const isAdmin = page.props.auth.user.is_admin;
</script>

<template>
    <Head title="Dashboard" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">Dashboard</h2>
        </template>

        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                
                <div v-if="isAdmin" class="mb-4">
                    <Link :href="route('tasks.create')" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                        Assign New Task
                    </Link>
                </div>

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 text-gray-900">
                        <div v-if="page.props.flash.message" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                            <span class="block sm:inline">{{ page.props.flash.message }}</span>
                        </div>
                        <h3 v-if="isAdmin" class="text-lg font-medium text-gray-900 mb-4">All Tasks</h3>
                        <h3 v-else class="text-lg font-medium text-gray-900 mb-4">Your Assigned Tasks</h3>

                        <div v-if="tasks.length > 0">
                            <div v-for="task in tasks" :key="task.id" class="p-4 mb-4 border rounded-lg">
                                <div class="flex justify-between items-center">
                                    <div>
                                        <h4 class="font-bold">{{ task.title }}</h4>
                                        <p class="text-gray-600">{{ task.description }}</p>
                                        <p class="text-sm text-gray-500">Deadline: {{ task.deadline ?? 'N/A' }}</p>

                                        <p v-if="isAdmin && task.user" class="text-sm font-semibold text-blue-700 mt-2">
                                            Assigned To: {{ task.user.name }}
                                        </p>
                                    </div>
                                    <div>

                                        <select v-if="!isAdmin" v-model="task.status" @change="updateTaskStatus(task)" class="rounded-md shadow-sm border-gray-300">
                                            <option value="Pending">Pending</option>
                                            <option value="In Progress">In Progress</option>
                                            <option value="Completed">Completed</option>
                                        </select>
                                        
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