capture log close
clear *

capture cd "C:\Users\dsder\OneDrive\Desktop\RA\COMET"
capture cd "C:\Users\situ_\OneDrive\Desktop\RA\COMET"

global data_dir ".\data"
global script_dir ".\do_files"
global log_dir ".\logs" 

log using "$log_dir\comet_p2_log.txt", text replace

use "$data_dir\fake_data.dta", clear

gen female = sex == "F"

// Interaction terms //
reg earnings i.female##c.age
	// prefix factors with i., continuous vars with c., and separate with ##
	
reg earnings i.female##i.region

// Outreg2 //
clear*
sysuse auto, clear
outreg2 using myfile, sum(log) replace eqdrop(N mean) see
* outreg2 using myfile, sum(detail) replace eqkeep(N max min) see
* outreg2 using myfile, sum(detail) onecol replace see

capture log close
