#!/bin/sh

rpl '&A' '&amp;A' *.xml
rpl '&J' '&amp;J' *.xml
rpl '&M' '&amp;M' *.xml
rpl '&S' '&amp;S' *.xml
rpl '&T' '&amp;T' *.xml
rpl ' & ' ' &amp; ' *.xml
rpl '"&"' '""' *.xml
