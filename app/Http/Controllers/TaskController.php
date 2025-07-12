<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\User;
use App\Mail\TaskAssignedMail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Inertia\Inertia;

class TaskController extends Controller
{
    public function dashboard()
    {
        $user = auth()->user();
        $tasks = []; // Initialize tasks array

        if ($user->is_admin) {
            // If the user is an admin, get ALL tasks.
            // Use with('user') to eager load the user's name to prevent extra database queries.
            // Use latest() to show the newest tasks first.
            $tasks = Task::with('user')->latest()->get();
        } else {
            // If a regular user, get only their tasks.
            $tasks = Task::where('user_id', $user->id)->latest()->get();
        }

        return Inertia::render('Dashboard', [
            'tasks' => $tasks,
        ]);
    }

    public function create()
    {
        $users = User::where('is_admin', false)->get();
        return Inertia::render('Tasks/Create', [
            'users' => $users
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'deadline' => 'nullable|date',
            'user_id' => 'required|exists:users,id',
        ]);

        $task = Task::create($request->all());
        $user = User::find($request->user_id);
        Mail::to($user)->send(new TaskAssignedMail($task));

        // Redirect back with a flash message
        return redirect()->route('dashboard')->with('message', 'Task assigned successfully!');
    }

    public function update(Request $request, Task $task)
    {
        if ($task->user_id !== auth()->id()) {
            abort(403);
        }
        $request->validate([
            'status' => 'required|in:Pending,In Progress,Completed',
        ]);
        $task->update(['status' => $request->status]);

        // Redirect back with a flash message
        return redirect()->route('dashboard')->with('message', 'Task status updated!');
    }
}