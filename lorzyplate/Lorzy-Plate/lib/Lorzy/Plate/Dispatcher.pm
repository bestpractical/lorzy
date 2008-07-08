#!/usr/bin/env perl
package Lorzy::Plate::Dispatcher;
use Jifty::Dispatcher -base;

on qr'^/(?:|index.html)$' => run {
    redirect '/lorzy';
};

1;

