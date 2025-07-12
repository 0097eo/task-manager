@component('mail::message')
# A New Task Has Been Assigned to You

Hi there,

A new task has been assigned to you by an administrator.

**Task Title:** {{ $task->title }}
**Description:** {{ $task->description }}
**Deadline:** {{ $task->deadline }}

You can view and update your tasks on your dashboard.

@component('mail::button', ['url' => config('app.url') . '/dashboard'])
Go to Dashboard
@endcomponent

Thanks,<br>
{{ config('app.name') }}
@endcomponent