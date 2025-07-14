<?php

return [
    /*
     * Set trusted proxy IP addresses.
     * Both IPv4 and IPv6 addresses are supported, along with CIDR notation.
     * The "*" character is syntactic sugar within TrustedProxy to trust any proxy
     * that connects directly to your server, a requirement when you cannot know
     * the address of your proxy (e.g. if using Render, Heroku, etc).
     */
    'proxies' => '*', // Trust all proxies for platforms like Render

    /*
     * Which headers to use to detect proxy behavior.
     * For Render and most cloud platforms, use the following headers:
     */
    'headers' => [
        (defined('Illuminate\Http\Request::HEADER_FORWARDED') ? Illuminate\Http\Request::HEADER_FORWARDED : 'forwarded') => 'FORWARDED',
        (defined('Illuminate\Http\Request::HEADER_X_FORWARDED_FOR') ? Illuminate\Http\Request::HEADER_X_FORWARDED_FOR : 'x-forwarded-for') => 'X_FORWARDED_FOR',
        (defined('Illuminate\Http\Request::HEADER_X_FORWARDED_HOST') ? Illuminate\Http\Request::HEADER_X_FORWARDED_HOST : 'x-forwarded-host') => 'X_FORWARDED_HOST',
        (defined('Illuminate\Http\Request::HEADER_X_FORWARDED_PORT') ? Illuminate\Http\Request::HEADER_X_FORWARDED_PORT : 'x-forwarded-port') => 'X_FORWARDED_PORT',
        (defined('Illuminate\Http\Request::HEADER_X_FORWARDED_PROTO') ? Illuminate\Http\Request::HEADER_X_FORWARDED_PROTO : 'x-forwarded-proto') => 'X_FORWARDED_PROTO',
    ],
];