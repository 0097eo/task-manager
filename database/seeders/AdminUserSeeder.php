<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::firstOrCreate(
            // Use email as the unique identifier to find the user
            ['email' => 'taskmanager@example.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('password'), // Use a secure default password
                'is_admin' => true,
            ]
        );
    }
}