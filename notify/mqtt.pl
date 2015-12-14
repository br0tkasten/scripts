#!/usr/bin/perl
use strict;
use warnings;

use Net::MQTT::Simple;

my $mqtt = Net::MQTT::Simple->new("br0tkasten.de");

$mqtt->publish("test/foo" => "hobaguagal");

