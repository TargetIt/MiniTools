#!/usr/bin/perl
# -------------------------------------------------------------------------
#
#
#
# File    : PINMUX
# Author  : 
# Created :  
# Abstract: PINMUX is a script for generating pin_mux circuit,   
#
# -------------------------------------------------------------------------
# Revision:  
# -------------------------------------------------------------------------
use POSIX;
use Getopt::Long;     # -- Command-line Options decoder with long options
# --------------------------------------------------------
# Generate local time 
# --------------------------------------------------------
my $date = localtime;
my @myTIME = split /\s+|:/ , $date;
my $wday = $myTIME[0];
my $mon  = $myTIME[1];
my $mday = $myTIME[2];
my $hour = $myTIME[3];
my $min  = $myTIME[4];
my $sec  = $myTIME[5];
my $year = $myTIME[6];

my $acc_file_output = "pin_mux_$year-$mon-$mday-$hour:$min:$sec.v";
# ---------------------------------------------------------
# 
# ---------------------------------------------------------
$Head_tag=<<EndofUsage,
// -------------------------------------------------------
//
// Version:  v0.0
// Author :  $ENV{'USER'}
// Time   :  $year-$mon-$mday-$hour:$min:$sec
//
// -------------------------------------------------------
EndofUsage

$Success_tag=<<EndofUsage,

// ------------------Successful---------------------						

 The output file located in current directory.   
 The output file named pin_mux_$year-$mon-$mday-$hour:$min:$sec.v"   
EndofUsage
# ---------------------------------------------------------
# --help 
# ---------------------------------------------------------
$Showhelp=<<EndofUsage,

Options: Global:

	--help						Print this usage message

Options:  What stimulus to provide:

	--pad_lib <filename_pad>			Read PAD library message from <filename_pad>

	--mux_table <filename_mux>			Read Pin_mux table from	<filename_mux>

	--func_num <number_func>			Specify how many functions are reused at most by <number_func>

	--test_num <number_test>			Specify how many testmodes are reused at most by <number_test>

	--test_mode <filename_mode>			Read the name of test mode from <filename_mode>

EndofUsage

GetOptions (  'help|h'                   => \$help
            , 'pad_lib=s'                => \$pad_lib
            , 'mux_table=s'              => \$mux_table
            , 'func_num=s'               => \$func_num
            , 'test_num=s'               => \$test_num
            , 'test_mode=s'              => \$test_mode          
			) or die "$Showhelp";
if($help){
		print "$Showhelp\n";
		exit 0; 
		}
# -/ ------------------------------------------------------
# -/ Judge whether Input arguments are complete  
# -/ ------------------------------------------------------ 
my $err_num = 0;
my $err_std = ();
# Print errors about input arguments if exist
if($pad_lib  =~ /(^-)|(^\s*$)/) {
	$err_num ++;
	$err_std .= sprintf "ERROR: plese specify your pad library by Option : --pad_lib <filename_pad> \n"; 
	};
if($mux_table =~ /(^-)|(^\s*$)/) { 
	$err_num ++;
	$err_std .= sprintf "ERROR: plese specify your pin_mux table by Option : --mux_table <filename_mux> \n"; 
	};
if(($func_num =~ /(^-)|(^\s*$)/) | !($func_num =~ /^\d+$/)) { 
	$err_num ++;
	$err_std .= sprintf "ERROR: plese specify your function number by Option : --func_num <number_func> \n"; 
	};
if(($test_num =~ /(^-)|(^\s*$)/) | !($test_num =~ /^\d+$/)) { 
	$err_num ++;
	$err_std .= sprintf "ERROR: plese specify your test number by Option : --test_num <number_test> \n"; 
	};
if(($test_mode =~ /(^-)/) | (!($test_num =~ /^\s*0\s*$/) & ($test_mode =~ /^\s*$/)) ) {
	$err_num ++;
	$err_std .= sprintf "ERROR: plese specify your test mode by Option : --test_mode <filename_mode> \n"; 
	}
if($err_num > 0){
	print "$err_std \n";
	print "$Showhelp\n";
	exit 0;
	}
# Print what inputs
print "// ----------Here is your input Options: -----------\n\n";
print "\t--pad_lib $pad_lib\n";
print "\t--mux_table $mux_table\n";
print "\t--test_mode $test_mode\n";
print "\t--func_nume $func_num\n";
print "\t--test_num $test_num\n";

# -/ ==================================================================
# -/
# -/                          ACCESS LAYER
# -/
# -/ ==================================================================
open FILE_PAD_LIB,'<',$pad_lib or die "Fail to read file <filename_pad> : $pad_lib !";
if(!($test_num =~ /^\s*0\s*$/)){
open FILE_TEST_MODE,'<',$test_mode or die "Fail to read file <filename_mode> : $test_mode ";
}
# -/ ------------------------------------------------------
# -/ Read PAD library from file $pad_lib
# -/ ------------------------------------------------------ 
  my $num_type =0;
  my $acc_PAD_IN		= ();	 
  my $acc_IN_default	= ();	
  my $acc_PAD_IE		= ();	
  my $acc_IE_default	= ();	
  my $acc_PAD_OUT		= (); 
  my $acc_OUT_default	= (); 
  my @acc_SW_NAME		= (); 
  my @acc_SW_WIDTH		= ();	
  my @acc_SW_DEFAULT	= ();

  while(<FILE_PAD_LIB>){
  	chomp($_);
  	$_ =~ s/\s+//g;	#substitue all white space character;
      my @array = split /,|;|:/, $_;
  	my $len = $#array;
  	if($_ =~ /^#1/){
  		$num_type ++;	
  		}
  	elsif($_ =~ /^#2/){
  		$num_type ++;
  		}
  	elsif($_ =~ /^#3/){
  		$num_type ++;
  		}
  	elsif($_ =~ /^#4/){
  		$num_type ++;
  		}
  	elsif($_ =~ /^#5/){
  		$num_type ++;
  		}
	# ERROR checking 
  	if(($num_type!=0) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
		if($len != 3){
			die "ERROR: Please check your file : $pad_lib Line : $.";	
			}	
		}
	# 
  	if(($num_type==1) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
  		$acc_PAD_IN = $array[0];
  		$acc_IN_default = $array[2]."'d".$array[3];
  		}
  	if(($num_type==2) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
  		$acc_PAD_IE = $array[0];
  		$acc_IE_default = $array[2]."'d".$array[3];
  		}
  	if(($num_type==3) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
  		$acc_PAD_OUT = $array[0];
  		$acc_OUT_default = $array[2]."'d".$array[3];
  		}
  	if(($num_type==4) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
  		$acc_PAD_OEN = $array[0];
  		$acc_OEN_default = $array[2]."'d".$array[3];
  		}
  	if(($num_type==5) & !($_ =~ /^#/) & !($_ =~ /^\s*$/ )){
  		push(@acc_SW_NAME, $array[0]);
  		push(@acc_SW_WIDTH, $array[2]);
  		push(@acc_SW_DEFAULT, $array[3]);
  		}
  	}
# ERROR checking
if($num_type<5){die "Please check your file $pad_lib, it should include 5 different types !";}
	close FILE_PAD_LIB;
# -/ ------------------------------------------------------
# -/ Read test mode information from file  $test_mode
# -/ ------------------------------------------------------ 
while(<FILE_TEST_MODE>){
	chomp($_);
	$_ =~ s/\s+//g;	#substitue all white space character;
    my @array = split /,|;|:/, $_;
	@acc_MODE = @array;
	}
close FILE_TEST_MODE;
#

my $acc_file_input = $mux_table;
my $acc_num_func = $func_num;
my $acc_num_test = $test_num;

# -/ ------------------------------------------------------
# -/ Invoke pinmux_gen function to generate pin_mux.v 
# -/ ------------------------------------------------------ 
#  &PINMUX_CORE::pinmux_gen(
#   $acc_file_input		,	 
#   $acc_file_output		, 	
#   $acc_num_func 			,	
#   $acc_num_test 			,	
#   $acc_PAD_IN 			,	
#   $acc_PAD_IE 			,	
#   $acc_PAD_OUT 			,	
#   $acc_PAD_OEN 			,	
#   \@acc_MODE 				,	
#   \@acc_SW_NAME 			,	
#   \@acc_SW_WIDTH 			,	
#   \@acc_SW_DEFAULT	
#  	);
#	my $acc_OEN_default = 1;
#	my $acc_OUT_default = 0;
#	my $acc_IE_default  = 0;
#	my $acc_IN_default  = 0;

# -/ ==================================================================
# -/
# -/                          PINMUX_SUB
# -/
# -/ ==================================================================

# -/ ------------------------------------------------------------
# -/ PORT LIST
# -/ Usage format:
# -/ PORT_LIST_namearray($prefix, \@name, $postfix) 
# -/ PORT_LIST_postarray($prefix, $name, \@postfix)
# -/ PORT_LIST_normal($prefix, $name, $postfix)
# -/ ------------------------------------------------------------
sub PORT_LIST_MODE{
	my ($mymode) = @_;
	my @myMODE = @$mymode;
	my $myPORT_LIST_MODE = "";
	my $mylen = $#myMODE;
	for(my $num=0;$num<=$mylen;$num++ ){
		$myMODE_LIST .= sprintf"\t%s,\n", $myMODE[$num]."_MODE"; }
	return($myMODE_LIST);
	}
	
sub PORT_LIST_namearray{
	my($prefix, $name, $postfix) = @_;	
	my @myNAME = @$name;
	my $mylen = $#myNAME;
	my $myPORT_LIST_namearray = "";
	for(my $num;$num<=$mylen;$num++){
		$myPORT_LIST_namearray .= sprintf "\t%s%s_%s,\n", $prefix,$myNAME[$num],$postfix;
		}
	return($myPORT_LIST_namearray);
	}

sub PORT_LIST_postarray{
	my($prefix, $name, $postfix) = @_;	
	my @myPOSTFIX = @$postfix;
	my $mylen = $#myPOSTFIX;
	my $myPORT_LIST_postarray = "";
	for(my $num;$num<=$mylen;$num++){
		$myPORT_LIST_postarray .= sprintf "\t%s%s_%s,\n", $prefix,$name,$myPOSTFIX[$num];
		}
	return($myPORT_LIST_postarray);
	}

sub PORT_LIST_normal{
	my($prefix, $name, $postfix) = @_;	
	my $myPORT_LIST_normal .= ""; 
	$myPORT_LIST_normal .= sprintf "\t%s%s_%s,\n", $prefix,$name,$postfix;
	return($myPORT_LIST_normal);
	}

# -/ ------------------------------------------------------------
# -/ INPUT and OUTPUT declaration 
# -/ ------------------------------------------------------------
sub PORT_DECL_MODE{
	my ($mymode) = @_;
	my @myMODE = @$mymode;
	my $myPORT_DECL_MODE = "";
	my $mylen = $#myMODE;
	for(my $num=0;$num<=$mylen;$num++ ){
		$myMODE_DECL .= sprintf"\tinput %s;\n", $myMODE[$num]."_MODE"; 
		}
	return($myMODE_DECL);
	}
# -------------------------------- 
sub PORT_GEN{
	my ($mydir, $myname) = @_;
	my $myPORT_GEN = "";
$myPORT_GEN =<<EndofUsage,
	$mydir	$myname;
EndofUsage
	return($myPORT_GEN);
	}
#name and postfix must be array.

# -/ ------------------------------------------------------------
# -/ Usage format: 
# -/ &INOUTPUT_GEN($mydir,\@myname, $mypostfix);
# -/ ------------------------------------------------------------
sub INOUTPUT_GEN{
	my ($mydir, $myname, $mypostfix) = @_;
	my @myNAME = @$myname;
	my $mylen1 = $#myNAME;
	my $myINOUTPUT_GEN = "";
	for(my $num=0; $num<=$mylen1; $num++){
			$myINOUTPUT_GEN .= &PORT_GEN($mydir,$myNAME[$num]."_".$mypostfix);
		}
	return($myINOUTPUT_GEN);
	}
# -/ ------------------------------------------------------------
# -/ for generate PAD side, output of PINMUX
# -/ generate the code like this
# -/ 	output 		io_FUNC1_IE;
# -/ 	output 		io_FUNC1_OEN;
# -/ 	output 		io_FUNC1_I;
# -/ 	output 		io_FUNC1_REN;
# -/ prototype
# -/ usage format:
# -/ 	&SW_DIR_GEN($mydir,$myprefix,$myname,\@mypostfix);	
# -/ ------------------------------------------------------------
sub SW_DIR_GEN{
	my ($mydir,$mywidth,$myprefix,$myname,$mypostfix) = @_;
	my @myWIDTH = @$mywidth;
	my @myPOSTFIX = @$mypostfix;
	my $mylen = $#myPOSTFIX;
	my $mySW_DIR_GEN = "";
	for(my $num=0; $num<=$mylen; $num++){
		if($myWIDTH[$num]>1){
			my $width = $myWIDTH[$num]-1;
			$mySW_DIR_GEN .= &PORT_GEN($mydir."[".$width.":0]", $myprefix."_".$myname."_".$myPOSTFIX[$num]);
			}
		else {
			$mySW_DIR_GEN .= &PORT_GEN($mydir, $myprefix."_".$myname."_".$myPOSTFIX[$num]);
			}
		}
	return($mySW_DIR_GEN);
	}

# -/ ------------------------------------------------------------
# -/ Generate some special direction declare
# -/ 	input 		io_FUNC1_C;
# -/ 	input[1:0] 	sw_FUNC1_SEL;
# -/ 	input 		sw_FUNC1_REN;
# -/ usage format:
# -/  &NORM_DIR_GEN($mydir,$mywidth,$myprefix,$myname,$mypostfix);
# -/ ------------------------------------------------------------
sub NORM_DIR_GEN{
	my ($mydir,$mywidth,$myprefix,$myname,$mypostfix) = @_;
	my $myNORM_DIR_GEN = "";
	$myNORM_DIR_GEN .= &PORT_GEN($mydir.$mywidth,$myprefix."_".$myname."_".$mypostfix);
	return($myNORM_DIR_GEN);
	}

# -/ ------------------------------------------------------------
# -/ Generate the code like this
# -/ 		assign io_FUNC1_REN = 
# -/ Usage format
# -/   &ASSIGN_GEN($myprefix, $myname, $mypostfix);
# -/ ------------------------------------------------------------
sub ASSIGN_GEN{
	my ($myprefix, $myname, $mypostfix) = @_;
	my $myASSIGN_GEN = "";
# $myASSIGN_GEN =<<EndofUsage,
#   assign $myprefix\_$myname\_$mypostfix = 
# EndofUsage
	my $tmp_string = $myprefix.$myname.$mypostfix;
	$myASSIGN_GEN = sprintf "  assign %-15s = \n", $tmp_string ;
	return($myASSIGN_GEN); 
	} 

# -/ ------------------------------------------------------------
# -/ Generate the code like this
# -/ 
# -/ SCAN_MODE 	? SCAN_OEN		: 
# -/ 
# -/ ------------------------------------------------------------
#BY qingpeng
sub MUX_GEN_QP{
	my($mymode, $mytest) = @_;
$TEST_SEL =<<EndofUsage,
		$mymode   ?	$mytest			:
EndofUsage
	return($TEST_SEL);
	}
#Written by PENG MINGGUO
sub MUX_GEN{
	my($mymode, $mytest) = @_;
	$TEST_SEL = sprintf "\t\t\t\t\t%-25s\t%s\t%-15s:\n",	$mymode, "?", $mytest ;
	return($TEST_SEL);
	}
		
# -/ ------------------------------- 
sub DEFAULT_GEN{
	my($myINPUT) = @_;
$myDEFAULT =<<EndofUsage,
					$myINPUT;
EndofUsage
	return($myDEFAULT);
}
# -/ ------------------------------------------------------------
# -/ Generate the code like this
# -/  SCAN_MODE 				? SCAN_IE 			: 
# -/  BIST_MODE 				? BIST_IE 			:
# -/  BSD_MODE	 				? BSD_IE			:
# -/  CODEC_TEST_MODE	 		? CODEC_TEST_IE		:
# -/  USBPHY_TEST_MODE	 		? USBPHY_TEST_IE	:
# -/  DEBUG_MODE	 			? DEBUG_IE			:
# -/ 
# -/  INPUT : $mymode_test, $myname_test, $mypostfix
# -/  EG	: SCAN			SCAN_IN1	  IE
# -/ Usage format
# -/ &TEST_GEN(\@mymode_test, \@myname_test, $mypostfix);
# -/ ------------------------------------------------------------
sub TEST_GEN{
     my($mymode_test, $myname_test, $mypostfix) = @_;
     my @myMODE_TEST = @$mymode_test;
     my @myNAME_TEST = @$myname_test;
     my $mylen = $#myNAME_TEST;
	 my $myTEST_GEN = "";
     for(my $num=0;$num<=$mylen;$num++){
		 if($myNAME_TEST[$num] =~ /^\d+/){
         	$myTEST_GEN .= &MUX_GEN($myMODE_TEST[$num]."_MODE",	$myNAME_TEST[$num]);
		 	}
		 else {
         	$myTEST_GEN .= &MUX_GEN($myMODE_TEST[$num]."_MODE", $myNAME_TEST[$num]."_".$mypostfix);
			 }
         }
     return($myTEST_GEN);
     }
# -/ ------------------------------------------------------------
# -/ Generate the code like:
# -/ 
# -/ 	(sw_FUNC1_SEL == 2'd2)	? FUNC3_IE 			:
# -/ 	(sw_FUNC1_SEL == 2'd1)	? FUNC2_IE 			:
# -/ 	(sw_FUNC1_SEL == 2'd0)	? FUNC1_IE 			:
# -/ 	FUNC1_IE;
# -/ Usage format:
# -/ &FUNC_GEN(\@myname_func, $mywidth, \@mynum_func, $mypostfix); 
# -/ ------------------------------------------------------------
sub FUNC_GEN{
	my ($myselect, $myname_func,$mywidth, $mynum_func, $mypostfix, $mydefault) = @_;
	#%myHASH_FUNC =reverse %$myhash; 	# makes the hash sort by number.
	my @myNAME_FUNC = @$myname_func;
	my @myNUM_FUNC  = @$mynum_func;
	my $mylen = $#myNAME_FUNC;
	my $myFUNC_GEN = "";
	if($mylen > 0){
	for ($num=$mylen;$num>=0;$num--){
		$myFUNC_GEN .= &MUX_GEN("(sw_".$myselect."_sel == ".$mywidth."'d".$myNUM_FUNC[$num].")",$myNAME_FUNC[$num]._.$mypostfix);
		}
		$myFUNC_GEN .= &DEFAULT_GEN($mydefault);
		}
	elsif($mylen == 0){
		if($mywidth >0){
		$myFUNC_GEN .= &MUX_GEN("(sw_".$myselect."_sel == ".$mywidth."'d".$myNUM_FUNC[0].")",$myNAME_FUNC[0]._.$mypostfix);
		$myFUNC_GEN .= &DEFAULT_GEN($mydefault);
		}
		else{
			$myFUNC_GEN .= &DEFAULT_GEN($myNAME_FUNC[0]._.$mypostfix);
			}
		}

#$myFUNC_GEN .=<<EndofUsage,
#					$myNAME_FUNC[0]_$mypostfix;
#EndofUsage
	return($myFUNC_GEN);
	}

# -/ ------------------------------------------------------------
# -/ Generate the code like this
# -/ 
# -/ assign io_FUNC1_REN = 
# -/ 					   (SCAN_MODE | BIST_MODE | BSD_MODE)? 1'b1 : 
# -/ 					   sw_FUNC1_REN;
# -/ 
# -/ ------------------------------------------------------------
sub SW_IO_CTRL{
	my($myfunc1, $mymode, $mypostfix, $dat_clamp1) = @_;
	my @myMODE = @$mymode;
	my $mylen = $#myMODE;
	my $sw_io_ctrl = "";
#$sw_io_ctrl =<<EndofUsage,
#  assign io_$myfunc1\_$mypostfix  = 
#EndofUsage
	my $tmp_string = io._.$myfunc1._.$mypostfix ;
	#$sw_io_ctrl = sprintf "  assign %-15s = \n" , $tmp_string;
	$sw_io_ctrl = &ASSIGN_GEN(io_,$myfunc1,_.$mypostfix);
	my $sw_temp = "";	#ERROR when for sentence followed EndofUsage;
	for(my $num=0; $num<=$mylen; $num++){
		if($num == 0){
			$sw_temp .= "(".$myMODE[$num]."_MODE ";
			}	
		else{
			$sw_temp .= "| ".$myMODE[$num]."_MODE ";
			}
		if($num == $mylen){
				$sw_temp .=")";
			}
		}	
	if($sw_temp =~ /^\s*$/){
		#Notice: the use of anchors
		#nothing to do, because nothing in $myMODE;
		}
	else {
		#$sw_io_ctrl .= &MUX_GEN($sw_temp, $dat_clamp1);
		$sw_io_ctrl .= sprintf"\t\t\t\t\t%-30s\t?\t%s\t:\n",$sw_temp, $dat_clamp1;
		}
$sw_io_ctrl .=<<EndofUsage,
					sw_$myfunc1\_$mypostfix; 
EndofUsage
	return ($sw_io_ctrl);
	}
# -/ ------------------------------------------------------------
# -/ 
# -/ Usage format:
# -/	&SW_ASSIGN_GEN($myfunc1, \@mymode, \@mypostfix, \@dat_clamp));
# -/ ------------------------------------------------------------
sub SW_ASSIGN_GEN{
	my ($myfunc1, $mymode, $mypostfix, $mywidth, $dat_clamp) = @_;
	my @myMODE = @$mymode;
	my @myPOSTFIX = @$mypostfix;
	my @myWIDTH = @$mywidth;
	my @myDAT_CLAMP = @$dat_clamp;
	my $mylen = $#myPOSTFIX;
	my $mySW_ASSIGN_GEN = "";
	for(my $num=0;$num<=$mylen;$num++){
		if($myWIDTH[$num]>1){
			my $width = $myWIDTH[$num];
			$mySW_ASSIGN_GEN .= &SW_IO_CTRL($myfunc1,\@myMODE,$myPOSTFIX[$num],$width."'d".$myDAT_CLAMP[$num]);	
			}
		else{ 
			$mySW_ASSIGN_GEN .= &SW_IO_CTRL($myfunc1,\@myMODE,$myPOSTFIX[$num],"1'd".$myDAT_CLAMP[$num]);	
			}
		}
	return($mySW_ASSIGN_GEN);	
	}
# -/ ------------------------------------------------------------
# -/ Generate the code like this:
# -/ 	assign SCAN_IN = SCAN_MODE 	? io_FUNC1_C : 1'b0;
# -/ 	assign BIST_IN = BIST_MODE 	? io_FUNC1_C : 1'b0;
# -/ Usage format
# -/ 	&ASSIGN_TEST_IN(\@test_in,\@mode_test_in,$func1,$pad_in);
# -/ ------------------------------------------------------------
sub ASSIGN_TEST_IN{
	my ($test_in, $mode_test_in,$func1,$pad_in,$in_default) = @_;
	my @myTEST_IN = @$test_in;
	my @myMODE_TEST_IN = @$mode_test_in;
	my $mylen = $#myTEST_IN;
	my $myASSIGN_TEST_IN = "";
	for (my $num=0;$num<=$mylen;$num++){
			my $assign_in = $myTEST_IN[$num]._.$pad_in;
			my $test_mode = $myMODE_TEST_IN[$num]._.MODE;
			my $io_FUNC1_IN = io._.$func1._.$pad_in;
			#$myASSIGN_TEST_IN .= sprintf "  assign %-15s = %-15s ?  %-15s :\t 1'b0;\n", $assign_in, $test_mode, $io_FUNC1_IN;
			$myASSIGN_TEST_IN .= &ASSIGN_GEN("",$assign_in,"");
			$myASSIGN_TEST_IN .= &MUX_GEN($test_mode,$io_FUNC1_IN);
			$myASSIGN_TEST_IN .= &DEFAULT_GEN($in_default);
		}
	return($myASSIGN_TEST_IN);
	}
# -/ ------------------------------------------------------------
# -/ Generate the code like this:
# -/ 	assign FUNC1_IN  		= io_FUNC1_C;
# -/ 	assign FUNC2_IN  		= io_FUNC1_C;
# -/ 	assign FUNC3_IN  		= io_FUNC1_C;
# -/ Usage format
# -/ 	&ASSIGN_FUNC_IN($prefix,\@func_in,$postfix);
# -/ ------------------------------------------------------------
sub ASSIGN_FUNC_IN{
	my ($myselect,$prefix,$func_in,$num_func_in,$wid_sel,$postfix,$in_default) = @_;
	my @myFUNC_IN = @$func_in;
	my @myNUM_FUNC_IN = @$num_func_in;
	my $mylen = $#myFUNC_IN;
	my $myASSIGN_FUNC_IN = "";
	###For sentenece excute from num=1;
	for($num=0;$num<=$mylen;$num++){
		my $assign_in = $myFUNC_IN[$num].$postfix;
		#my $io_FUNC1_IN = $prefix._.$myFUNC_IN[$num]._.$postfix;
		my $io_FUNC1_IN = $prefix.$myselect.$postfix;
		$myASSIGN_FUNC_IN .= &ASSIGN_GEN("",$assign_in,"");
		if($wid_sel>0){
			$myASSIGN_FUNC_IN .= &MUX_GEN("(sw_".$myselect."_sel == ".$wid_sel."'d".$myNUM_FUNC_IN[$num].")",$io_FUNC1_IN);
			$myASSIGN_FUNC_IN .= &DEFAULT_GEN($in_default);
			}
		elsif($wid_sel==0){
			$myASSIGN_FUNC_IN .= &DEFAULT_GEN($io_FUNC1_IN);
			}
		#$myASSIGN_FUNC_IN .= sprintf "  assign %-15s =  %-15s ;\n", $assign_in,$io_FUNC1_IN;
		}
	return($myASSIGN_FUNC_IN);
	}
#
sub ASSIGN_onlyFUNC1_IN{
	my($myFUNC_IN_0,$wid_sel,$num_func1_c,$postfix,$in_default)	= @_;
	my @NUM_FUNC1_C = @$num_func1_c;
	my $myASSIGN_onlyFUNC1 = ();
	foreach(@NUM_FUNC1_C){
		$myASSIGN_onlyFUNC1 .= &MUX_GEN("(sw_".$myFUNC_IN_0."_sel == ".$wid_sel."'d".$_.")",io_.$myFUNC_IN_0._.$postfix);	
		}
	$myASSIGN_onlyFUNC1 .= &DEFAULT_GEN($in_default);
	}
# -/ ------------------------------------------------------------
# -/ POST-PROCESSING 
# -/  delete repeated 
# -/  PORT declaration and PORT direction declaration
# -/ ------------------------------------------------------------
sub DELETE_REPEATED_LINE{
	 my ($myINPUT) = @_;
	 my @array_mid = split/\n/, $myINPUT;
	 my %count; 
	 my @array_post = grep { ++$count{ $_ } < 2; } @array_mid; 
	 my $myOUTPUT = join("\n",@array_post);
	 return($myOUTPUT);
	}
# -/ ==================================================================
# -/
# -/                          PINMUX_CORE
# -/
# -/ ==================================================================
# sub pinmux_gen{
# 	my(
#  $acc_file_input		,	 
#  $acc_file_output		, 	
#  $acc_num_func 			,	
#  $acc_num_test 			,	
#  $acc_PAD_IN 			,	
#  $acc_PAD_IE 			,	
#  $acc_PAD_OUT 			,	
#  $acc_PAD_OEN 			,	
#  $acc_MODE 				,	
#  $acc_SW_NAME 			,	
#  $acc_SW_WIDTH 			,	
#  $acc_SW_DEFAULT		 	
# 	)
# 	= @_;

# -----------------------------------------------------
# -/ Input arguements of PROCESSING LAYER
# -----------------------------------------------------

my   $file_input	 =	$acc_file_input ;
my   $file_output    =	$acc_file_output;
my   $num_func 	     =	$acc_num_func 	;	
my   $num_test 	     =	$acc_num_test 	;	
my   $PAD_IN 	     =	$acc_PAD_IN 	;	
my   $PAD_IE 	     =	$acc_PAD_IE 	;
my   $PAD_OUT 	     =	$acc_PAD_OUT 	;
my   $PAD_OEN 	     =	$acc_PAD_OEN 	;
my   @MODE 		     =	@acc_MODE 		;
my   @SW_NAME 	     =	@acc_SW_NAME 	;
my   @SW_WIDTH 	     =	@acc_SW_WIDTH 	;
my   @SW_DEFAULT     =	@acc_SW_DEFAULT ;
my   $OEN_default    =  $acc_OEN_default;
my   $OUT_default    =	$acc_OUT_default;
my   $IE_default     =	$acc_IE_default ;
my   $IN_default     =	$acc_IN_default ;
	
# -----------------------------------------------------
my @FUNCTION;
my @DIRFUNC;
my @TEST;
my @DIRTEST;
#
my $width_sel;
# -----------------------------------------------------
#Access layer

	## add test mode to port list	
	$PORT_LIST .= sprintf "\n  //TEST MODE\n"; #annotation
	$PORT_LIST .= &PORT_LIST_MODE(\@MODE);
	## add test mode to input port declaration list
	$myPORT_INPUT .= sprintf "\n  //TEST MODE\n"; #annotation
	$myPORT_INPUT .= &PORT_DECL_MODE(\@MODE); 

# -----------------------------------------------------
open FILE_IN,'<',$file_input or die "Can't read file $file_input : $! \n";
open FILE_OUT,'>',$file_output or die "can't write file $file_output \n";
while(<FILE_IN>){
	#chomp($_);
	my @array_temp= ();
	my @array= ();

	#METHOD 1: Method 1 has the bug, please see the eg below; 
	# 	$_ = GPIO1 , SCLK , TEST,, ,,,;
	# 	@array = "GPIO1,SCLK,TEST";
	#	@array should be "GPIO1,SCLK,TEST,,,,,";
	#$_ =~ s/\s+//g;	#substitute all white space character;
    #@array = split /,|;/, $_;

	#METHOD 2, chomp also will chop ",,,,,,"
	my @array_temp = split /,|;/, $_;
	foreach(@array_temp){
		$_ =~s/\s+//g;
		push(@array,$_);
		}
	
	my $length_array = $#array;
# ---------------------------------------------------------
# -/ ERROR detection.
# -/ detect Whether (num_func+num_test)*2 equals with $length_array+1
# ---------------------------------------------------------
my $ERROR_NUM_MISMATCH=<<EndofUsage,
ERROR at $file_input : line $.
ERROR type: Function number and Test number contradicts with your total input number.
EndofUsage
$ERROR_NUM_MISMATCH.= "";
if((($num_func+$num_test)*2) != ($length_array+1)) { die "$ERROR_NUM_MISMATCH \n";}
# -/ ==================================================================
# -/
# -/                          TRANSFORMATION LAYER
# -/
# -/ ==================================================================
	# -------------------
	#split array into ALL_FUNCTION and ALL_TEST
	#input:  $num_func; #$num_test; #$array ;
	my @ALL_FUNCTION = @array[0..2*$num_func-1];
	my @ALL_TEST = @array[2*$num_func..$length_array];
	# -------------------
	#split into this four parts
	#@FUNCTION
	#@DIRFUNC;
	#@TEST;
 	#@DIRTEST;
	my $len_all_func = $#ALL_FUNCTION;
	my $len_all_test = $#ALL_TEST;
	@FUNCTION = ();
	@DIRFUNC = ();
	@TEST = ();
	@DIRTEST = ();
	for(my $num=0;$num<=$len_all_func;$num++ ){
		if(($num%2)==0){
			push(@FUNCTION, $ALL_FUNCTION[$num]);
			}
		else{
			push(@DIRFUNC, $ALL_FUNCTION[$num]);
			}
		}
	for(my $num=0;$num<=$len_all_test;$num++ ){
		if(($num%2)==0){
			push(@TEST, $ALL_TEST[$num]);
			}
		else{
			push(@DIRTEST, $ALL_TEST[$num]);
			}
		}
	# -------------------
	my $num_function = 0;
	my $mylen_func = $#FUNCTION;
	for(my $num=0;$num<=$mylen_func;$num++){
			if($FUNCTION[$num] =~ /^\s*$/){
				
				}
			else{
				$num_function ++;		
				}
		}
	$width_sel = ceil(log($num_function)/log(2));
	# -------------------
	my $len_FUNCTION = $#FUNCTION;
	my $len_TEST = $#TEST;
	@FUNC_IN = ();
	@NUM_FUNC_IN = ();
	@FUNC_OUT = ();
	@NUM_FUNC_OUT = ();
	@TEST_IN = ();
	@MODE_TEST_IN = ();
	@TEST_OUT = ();
	@MODE_TEST_OUT = ();


	for(my $num=0;$num<=$len_FUNCTION;$num++){
	#ERROR detection
		if(($DIRFUNC[$num] =~ /^\s*$/) ^ ($FUNCTION[$num] =~ /^\s*$/)){
			die"ERROR at $file_input : line $. , Please check all FUNCTION and it's DIRECTION!\n";
			}
		elsif($DIRFUNC[$num] eq 'input'){
			push(@FUNC_IN, $FUNCTION[$num]);
			push(@NUM_FUNC_IN, $num);
			##
			}
		elsif($DIRFUNC[$num] eq 'output'){
			push(@FUNC_OUT, $FUNCTION[$num]);
			push(@NUM_FUNC_OUT, $num);
			##
			}
		elsif($DIRFUNC[$num] eq 'inout'){
			push(@FUNC_IN, $FUNCTION[$num]);
			push(@NUM_FUNC_IN, $num);
			push(@FUNC_OUT, $FUNCTION[$num]);
			push(@NUM_FUNC_OUT, $num);
			##
			}
		# when both DIRFUNC and FUNCTION are white space.
		elsif($DIRFUNC[$num] =~ /^\s*$/){
			#nothing to do, white space character.
			##
			}
		else{
			die "ERROR at $file_input : line $. , DIRECTION only can be input, output and inout !\n";
			}
		}

	my @myTEST_OEN =();
	my @myTEST_OUT =();
	my @myTEST_IE =();


	for(my $num=0;$num<=$len_TEST;$num++){
		if(($DIRTEST[$num]=~/^\s*$/) ^ ($TEST[$num]=~/^\s*$/)){
			die"ERROR at $file_input : line $. , Please check all TEST and it's DIRECTION!\n";
			}
		elsif($DIRTEST[$num] eq 'input'){
			push(@TEST_IN, $TEST[$num]);
			push(@MODE_TEST_IN, $MODE[$num]);
			##
			push(@myTEST_OEN, $OEN_default);
			push(@myTEST_OUT, $OUT_default);
			push(@myTEST_IE,  $TEST[$num]);
			}
		elsif($DIRTEST[$num] eq 'output'){
			push(@TEST_OUT, $TEST[$num]);
			push(@MODE_TEST_OUT, $MODE[$num]);
			##
			push(@myTEST_OEN, $TEST[$num]);
			push(@myTEST_OUT, $TEST[$num]);
			push(@myTEST_IE,  $IE_default);
			}
		elsif($DIRTEST[$num] =~ /^\s*$/){
			##
			push(@myTEST_OEN, $OEN_default);
			push(@myTEST_OUT, $OUT_default);
			push(@myTEST_IE,  $IE_default);
			#nothing to do, white space character.	
			}
		else{
			die "ERROR at $file_input : line $. , DIRECTION only can be input, output and inout !\n";
			}
		}
# ---------------------------------------------------
# -/ 20150120 add by qpeng
# -/ FUNCTION: splice the difference between two arrays.
# -/  Usage example
# -/ ----- INPUT ARGV -----
# -/ NUM_FUNC_IN = 0, 1, 3;
# -/ $width_sel = 3;
# -/ ----- OUTPUT ARGV ------
# -/ myNUM_FUNC1_C = 0,2,4,5,6,7,8
# ---------------------------------------------------
my @myNUM_FUNC1_C;
my @myNUM_FUNC_IN;
@myNUM_FUNC_IN = @NUM_FUNC_IN;
shift(@myNUM_FUNC_IN); # delete the 1st element "0"
my @myNUM_FUNC_ALL = (0..($width_sel**2-1));
my %myNUM_FUNC_IN_HASH;
foreach(@myNUM_FUNC_IN) {$myNUM_FUNC_IN_HASH{$_}++;}
@temp = %myDIFFERENCE;
foreach(@myNUM_FUNC_ALL){
	if(!$myNUM_FUNC_IN_HASH{$_}){
		push(@myNUM_FUNC1_C, $_);
		}
	}
# -/ ==================================================================
# -/
# -/                        PROCESSING LAYER
# -/
# -/ ==================================================================
	$PORT_LIST .=  sprintf "\n  //$FUNCTION[0]\n"; #annotation
	$PORT_LIST .=	&PORT_LIST_namearray("", \@FUNC_IN, $PAD_IE); 
	$PORT_LIST .=	&PORT_LIST_namearray("", \@FUNC_OUT, $PAD_OUT); 
	$PORT_LIST .=	&PORT_LIST_namearray("", \@FUNC_OUT, $PAD_OEN); 
	$PORT_LIST .=	&PORT_LIST_namearray("", \@TEST_IN, $PAD_IE); 
	$PORT_LIST .=	&PORT_LIST_namearray("", \@TEST_OUT, $PAD_OUT); 
	$PORT_LIST .=	&PORT_LIST_namearray("", \@TEST_OUT, $PAD_OEN);
	$PORT_LIST .=	&PORT_LIST_normal   ("io_", $FUNCTION[0], $PAD_IN);
	if($width_sel>0) {
	$PORT_LIST .=	&PORT_LIST_normal   ("sw_", $FUNCTION[0], sel);
		}
	$PORT_LIST .=	&PORT_LIST_postarray("sw_", $FUNCTION[0], \@SW_NAME);
	$PORT_LIST .=	&PORT_LIST_postarray("io_", $FUNCTION[0], \@SW_NAME);
	
	
	$PORT_LIST .=	&PORT_LIST_namearray("", \@TEST_IN, $PAD_IN);
	$PORT_LIST .=	&PORT_LIST_namearray("", \@FUNC_IN, $PAD_IN);
	$PORT_LIST .=	&PORT_LIST_normal   ("io_", $FUNCTION[0], $PAD_IE);
	$PORT_LIST .=	&PORT_LIST_normal   ("io_", $FUNCTION[0], $PAD_OUT);
	$PORT_LIST .=	&PORT_LIST_normal   ("io_", $FUNCTION[0], $PAD_OEN);
	
	#	PORT_LIST_postarray($prefix, $name, \@postfix)
	
	$myPORT_INPUT .= sprintf "\n  //$FUNCTION[0]\n"; #annotation
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@FUNC_IN, $PAD_IE);
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@FUNC_OUT, $PAD_OUT);
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@FUNC_OUT, $PAD_OEN);
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@TEST_IN, $PAD_IE);
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@TEST_OUT, $PAD_OUT);
	$myPORT_INPUT .= &INOUTPUT_GEN(input,\@TEST_OUT, $PAD_OEN);
	$myPORT_INPUT .= &NORM_DIR_GEN(input,"",io,$FUNCTION[0],$PAD_IN);
	if($width_sel>1) {
		my $wid = $width_sel-1;
	$myPORT_INPUT .= &NORM_DIR_GEN(input,"[".$wid.":0]",sw,$FUNCTION[0],sel);
		}
	elsif($width_sel==1){
	$myPORT_INPUT .= &NORM_DIR_GEN(input,"",sw,$FUNCTION[0],sel);
		}
	$myPORT_INPUT .= &SW_DIR_GEN(input,\@SW_WIDTH,sw,$FUNCTION[0],\@SW_NAME);	
	
	$myPORT_OUTPUT .= sprintf "\n  //$FUNCTION[0]\n"; #annotation
	$myPORT_OUTPUT .= &INOUTPUT_GEN(output,\@TEST_IN, $PAD_IN);
	$myPORT_OUTPUT .= &INOUTPUT_GEN(output,\@FUNC_IN, $PAD_IN);
	$myPORT_OUTPUT .= &NORM_DIR_GEN(output,"",io,$FUNCTION[0],$PAD_OUT);
	$myPORT_OUTPUT .= &NORM_DIR_GEN(output,"",io,$FUNCTION[0],$PAD_OEN);
	$myPORT_OUTPUT .= &SW_DIR_GEN(output,\@SW_WIDTH,io,$FUNCTION[0],\@SW_NAME);	
	
	#
	#$myASSIGN .= &ASSIGN_GEN($myprefix, $myname, $mypostfix);
	#$myASSIGN .= &TEST_GEN(\@mymode_test, \@myname_test, $mypostfix);
	#$myASSIGN .= &FUNC_GEN(\@myname_func, \@mynum_func, $mypostfix); 
	
	$myASSIGN .= sprintf "\n  //$FUNCTION[0]\n"; #annotation
	$myASSIGN .= &ASSIGN_GEN(io_, $FUNCTION[0], _.$PAD_OEN);
	$myPORT_OUTPUT .= &NORM_DIR_GEN(output,"",io,$FUNCTION[0],$PAD_IE);
	#$myASSIGN .= &TEST_GEN(\@MODE_TEST_OUT, \@TEST_OUT, $PAD_OEN);
	$myASSIGN .= &TEST_GEN(\@MODE, \@myTEST_OEN, $PAD_OEN);
	$myASSIGN .= &FUNC_GEN($FUNCTION[0],\@FUNC_OUT, $width_sel, \@NUM_FUNC_OUT, $PAD_OEN, $OEN_default);
	
	$myASSIGN .= &ASSIGN_GEN(io_, $FUNCTION[0], _.$PAD_OUT);
	#$myASSIGN .= &TEST_GEN(\@MODE_TEST_OUT, \@TEST_OUT, $PAD_OUT);
	$myASSIGN .= &TEST_GEN(\@MODE, \@myTEST_OUT, $PAD_OUT);
	$myASSIGN .= &FUNC_GEN($FUNCTION[0],\@FUNC_OUT, $width_sel, \@NUM_FUNC_OUT, $PAD_OUT, $OUT_default);
	
	$myASSIGN .= &ASSIGN_GEN(io_, $FUNCTION[0], _.$PAD_IE);
	#$myASSIGN .= &TEST_GEN(\@MODE_TEST_IN, \@TEST_IN, $PAD_IE);
	$myASSIGN .= &TEST_GEN(\@MODE, \@myTEST_IE, $PAD_IE);
	$myASSIGN .= &FUNC_GEN($FUNCTION[0],\@FUNC_IN, $width_sel, \@NUM_FUNC_IN, $PAD_IE, $IE_default);
	
	$myASSIGN .= &SW_ASSIGN_GEN($FUNCTION[0], \@MODE, \@SW_NAME,\@SW_WIDTH, \@SW_DEFAULT);
	
	#	&ASSIGN_TEST_IN(\@test_in,\@mode_test_in,$func1,$pad_in);
	$myASSIGN .= &ASSIGN_TEST_IN(\@TEST_IN,\@MODE_TEST_IN,$FUNCTION[0],$PAD_IN,$IN_default);
	#	&ASSIGN_FUNC_IN($prefix,\@func_in,$postfix);
	#$myASSIGN .= &ASSIGN_FUNC_IN(io_,\@FUNC_IN,\@NUM_FUNC_IN,_.$PAD_IN);
	#$myASSIGN .= &ASSIGN_GEN("", $FUNCTION[0], _.$PAD_IN);
	#$myASSIGN .= &ASSIGN_onlyFUNC1_IN($FUNCTION[0],$width_sel,\@myNUM_FUNC1_C,$PAD_IN,$IN_default);
	$myASSIGN .= &ASSIGN_FUNC_IN($FUNCTION[0],io_,\@FUNC_IN,\@NUM_FUNC_IN,$width_sel,_.$PAD_IN,$IN_default);

	}

	chop($PORT_LIST);	# Chop the last symbol "\n"
	chop($PORT_LIST);	# Chop the last symbol ","
	# ----------------------------------------
	#POST-PROCESSING 
	#$PORT_LIST = join(',', split(',', $PORT_LIST));
	# delete repeated line
	# PORT declaration and PORT direction declaration	
	 $PORT_LIST = &DELETE_REPEATED_LINE($PORT_LIST);
	 $myPORT_INPUT = &DELETE_REPEATED_LINE($myPORT_INPUT);
	 $myPORT_OUTPUT = &DELETE_REPEATED_LINE($myPORT_OUTPUT);
	# ----------------------------------------
	## print to file : pin_mux.v
	print FILE_OUT "$Head_tag \n";
	print FILE_OUT "module pin_mux(\n";
	print FILE_OUT  "$PORT_LIST";
	print FILE_OUT "\n );\n";
	print FILE_OUT "$myPORT_INPUT \n";
	print FILE_OUT  "$myPORT_OUTPUT \n";
	print FILE_OUT  "$myASSIGN \n";
	print FILE_OUT "\n endmodule";

print "$Success_tag\n";

close FILE_IN;
close FILE_OUT;
