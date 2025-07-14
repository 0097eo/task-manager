# Task Manager - A Laravel & Vue.js Application

This is a full-stack task management system. It features role-based access control for administrators and regular users, task assignment, status tracking, and email notifications. The backend is powered by Laravel and the frontend is a modern, responsive Single-Page Application (SPA) built with Vue.js and Inertia.js.

The live, deployed version of this application can be viewed here:
**[https://task-manager-2ytx.onrender.com/](https://task-manager-2ytx.onrender.com/)**

**Default Admin Credentials:**
*   **Email:** `taskmanager@example.com`
*   **Password:** `password`

---

## Features

-   **User Authentication:** Secure user registration and login system.
-   **Role-Based Access Control:**
    -   **Administrators** can create, edit, and delete users.
    -   **Administrators** can assign tasks to any non-admin user.
    -   **Administrators** have a dashboard overview of all tasks in the system.
-   **Task Management:**
    -   Tasks have a title, description, status, and deadline.
    -   Task statuses include: `Pending`, `In Progress`, `Completed`.
-   **User Dashboard:**
    -   Users can view a list of all tasks assigned to them.
    -   Users can update the status of their own tasks.
-   **Email Notifications:**
    -   Users receive an email notification via Gmail SMTP when a new task is assigned to them.
-   **Modern Frontend:**
    -   A fast and responsive SPA experience built with Vue.js and Inertia.js.
    -   Polished UI with custom modals for destructive actions like deleting a user.

---

## Technical Stack

-   **Backend:** PHP 8.2 / Laravel 11
-   **Frontend:** Vue.js 3 / Inertia.js
-   **Database:** PostgreSQL (for production), SQLite (for local development)
-   **Styling:** Tailwind CSS
-   **Deployment:** Docker / Nginx / PHP-FPM on Render

---

## Local Development Setup

To run this project on your local machine, please follow these steps.

### Prerequisites

-   PHP 8.2+
-   Composer
-   Node.js & NPM
-   A local database (SQLite is the default, but PostgreSQL is recommended for full feature parity with production).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/0097eo/task-manager.git
    cd task-manager
    ```

2.  **Install PHP dependencies:**
    ```bash
    composer install
    ```

3.  **Install NPM dependencies:**
    ```bash
    npm install
    ```

4.  **Set up your environment file:**
    Copy the example environment file and generate your application key.
    ```bash
    cp .env.example .env
    php artisan key:generate
    ```

5.  **Configure your `.env` file:**
    Open the `.env` file and configure your database settings. For a quick start with zero configuration, you can use SQLite.
    
    **For SQLite:**
    ```env
    DB_CONNECTION=sqlite
    ```
    Then, create the database file:
    ```bash
    touch database/database.sqlite
    ```

    **For PostgreSQL (Recommended):**
    ```env
    DB_CONNECTION=pgsql
    DB_HOST=127.0.0.1
    DB_PORT=5432
    DB_DATABASE=task_manager_db
    DB_USERNAME=your_db_user
    DB_PASSWORD=your_db_password
    ```

6.  **Run database migrations and seed the database:**
    This command will create all necessary tables and create the default admin user.
    ```bash
    php artisan migrate:fresh --seed
    ```

7.  **Build frontend assets:**
    ```bash
    npm run build
    ```

8.  **Run the development servers:**
    You will need two separate terminal windows.

    *   **Terminal 1 (Vite Dev Server):**
        ```bash
        npm run dev
        ```
    *   **Terminal 2 (Laravel Server):**
        ```bash
        php artisan serve
        ```

You can now access the application at `http://127.0.0.1:8000`.

---

## Deployment

This application is configured for zero-downtime deployment on [Render](https://render.com/) using a multi-stage `Dockerfile`.

The deployment process includes:
-   **A `builder` stage** that installs all PHP and Node.js dependencies, generates the Ziggy route file, and builds the frontend assets.
-   **A final `production` stage** that starts from a clean PHP-FPM image and copies only the necessary compiled assets and vendor files.
-   **Nginx** as the web server and **Supervisor** as the process manager for both Nginx and PHP-FPM.
-   An **entrypoint script** that clears caches, runs database migrations, and dynamically configures the Nginx port based on Render's environment variables.

For a full breakdown of the deployment configuration, please see the `Dockerfile` and the files within the root directory.