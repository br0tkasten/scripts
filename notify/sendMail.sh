#!/bin/sh

echo "" | mailx -s "motion detected" -a $1 'motion@example.org'
