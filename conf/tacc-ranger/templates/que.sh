#!/bin/bash

cd %(rundir)r
echo "$( date ): %(code)s qued with ID: $( qsub script )" >> log

