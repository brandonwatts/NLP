package DocumentManipulation;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Wiki Parser
# 4/10/17

######## SUMMARY #########

# This program is a rudimentary Question and answering system using Wikipedia as a backend. It attempts to answer four basic 
# types of questions: Who, What, When or Where by means of query rewriting and direct regex matching.

######### ALGORITHIMS ########

#   There were really no major alogorithims used in this iteration of the QA system but I will decribe the method by which I 
#   turned a query into a response.
#
#   1) 
#   2) 
#   3) 
#   4) 

########## REFERENCES #########
# Exporter - http://perldoc.perl.org/Exporter.html
# Switch - http://perldoc.perl.org/5.8.8/Switch.html

use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT = qw( parseWikiData );


1;