#!/usr/bin/perl
#
#  Author: Preslav Nakov
#  
#  Description: Generates output for a random baseline + IR & gold standard labels
#               for SemEval-2016 Task 3, subtask A
#
#  Last modified: December 1, 2015
#
#

# Example run:
#    perl SemEval2016_task3_English_random_baseline_subtaskA.pl SemEval2016-Task3-CQA-QL-dev-subtaskA.xml
#    python MAP_scripts/ev.py SemEval2016-Task3-CQA-QL-dev-subtaskA.xml.subtaskA.relevancy SemEval2016-Task3-CQA-QL-dev-subtaskA.xml.subtaskA.pred



use warnings;
use strict;
use utf8;


################
###   MAIN   ###
################

die "Use $0 <INPUT_FILE>" if (0 != $#ARGV);
my $INPUT_FILE = $ARGV[0];
my $OUTPUT_FILE_RELEVANCY_GOLD = $INPUT_FILE . '.subtaskA.relevancy';
my $OUTPUT_FILE_BASELINE       = $INPUT_FILE . '.subtaskA.pred';

### 1. Open the files and 
open INPUT, $INPUT_FILE or die;
open OUTPUT_GOLD, '>' . $OUTPUT_FILE_RELEVANCY_GOLD or die;
open OUTPUT_BASELINE, '>' . $OUTPUT_FILE_BASELINE or die;
binmode(INPUT, ":utf8");
binmode(OUTPUT_GOLD, ":utf8");
binmode(OUTPUT_BASELINE, ":utf8");

srand 0;
while (<INPUT>) {

	#<RelComment RELC_ID="Q104_R1_C1" RELC_DATE="2010-08-27 01:40:05" RELC_USERID="U8" RELC_USERNAME="anonymous" RELC_RELEVANCE2ORGQ="Good" RELC_RELEVANCE2RELQ="Good">
	next if !/<RelComment RELC_ID=\"Q([0-9]+)_R([0-9]+)_C([0-9]+)\" [^<>]+ RELC_RELEVANCE2RELQ=\"([^\"]+)\"/;
	my ($qid, $relQID, $relCID, $rel2RelatedQ) = ($1, $2, $3, $4);
	my $rank  = $relCID;
	my $score = 1.0 / $rank;

	if ($rel2RelatedQ eq 'Good') { $rel2RelatedQ = 'true'; }
	elsif ($rel2RelatedQ eq 'Bad') { $rel2RelatedQ = 'false'; }
	elsif ($rel2RelatedQ eq 'PotentiallyUseful') { $rel2RelatedQ = 'false'; }
	else { die "Wrong value for RELC_RELEVANCE2RELQ: '$rel2RelatedQ'"; }

	print OUTPUT_GOLD "Q$qid\_R$relQID\tQ$qid\_R$relQID\_C$relCID\t$rank\t$score\t$rel2RelatedQ\n";

	$score = rand(2);
	my $label = ($score > 0.5) ? 'true' : 'false';
	print OUTPUT_BASELINE "Q$qid\_R$relQID\tQ$qid\_R$relQID\_C$relCID\t0\t$score\t$label\n";
}

### 3. Close the files
close INPUT or die;
close OUTPUT_GOLD or die;
close OUTPUT_BASELINE or die;
