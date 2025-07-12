<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    canLogin: {
        type: Boolean,
    },
    canRegister: {
        type: Boolean,
    },
});
</script>

<template>
    <Head title="Welcome" />
    <div class="relative min-h-screen flex flex-col items-center justify-center bg-white selection:bg-blue-500 selection:text-white">
        <nav v-if="canLogin" class="fixed top-0 right-0 p-6 text-end z-10">
            <Link
                v-if="$page.props.auth.user"
                :href="route('dashboard')"
                class="font-semibold text-gray-600 hover:text-gray-900 focus:outline focus:outline-2 focus:rounded-sm focus:outline-blue-500"
            >
                Dashboard
            </Link>

            <template v-else>
                <Link
                    :href="route('login')"
                    class="font-semibold text-gray-600 hover:text-gray-900 focus:outline focus:outline-2 focus:rounded-sm focus:outline-blue-500"
                >
                    Log in
                </Link>

                <Link
                    v-if="canRegister"
                    :href="route('register')"
                    class="ms-4 font-semibold text-gray-600 hover:text-gray-900 focus:outline focus:outline-2 focus:rounded-sm focus:outline-blue-500"
                >
                    Register
                </Link>
            </template>
        </nav>

        <div class="w-full max-w-4xl mx-auto p-6 lg:p-8 text-center">
            <div class="flex flex-col items-center">
                <svg class="h-20 w-20 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>

                <h1 class="mt-8 text-4xl font-bold text-gray-900 sm:text-5xl">
                    Welcome to Your Task Manager
                </h1>

                <p class="mt-4 text-lg leading-relaxed text-gray-600">
                    Stay organized, collaborate with your team, and get things done efficiently.
                    Log in or register to manage your tasks.
                </p>

                <div class="mt-10 flex items-center justify-center gap-x-6">
                    <Link
                        :href="route('login')"
                        class="rounded-md bg-blue-600 px-5 py-3 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
                    >
                        Get Started
                    </Link>
                    <a href="https://github.com/0097eo/task-manager" target="_blank" class="text-sm font-semibold leading-6 text-gray-900">
                        Learn more <span aria-hidden="true">→</span>
                    </a>
                </div>
            </div>
        </div>

        <footer class="absolute bottom-0 w-full py-6 text-center text-sm text-gray-500">
            Built with Laravel & Vue.js
        </footer>
    </div>
</template>