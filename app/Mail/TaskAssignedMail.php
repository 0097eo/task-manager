<?php
namespace App\Mail;
use App\Models\Task;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class TaskAssignedMail extends Mailable
{
    use Queueable, SerializesModels;
    public $task;
    public function __construct(Task $task)
    {
        $this->task = $task;
    }
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'New Task Assigned To You',
        );
    }
    public function content(): Content
    {
        return new Content(
            markdown: 'emails.tasks.assigned',
        );
    }
}