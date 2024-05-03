/* Documentation //
help regress
search regress
*/

// Logs, directories, and starting do-files //
capture log close
clear *

capture cd "C:\Users\dsder\OneDrive\Desktop\RA\COMET"
capture cd "C:\Users\situ_\OneDrive\Desktop\RA\COMET"
	// a way to address filepaths with teammates

global data_dir ".\data"
global script_dir ".\do_files"
global log_dir ".\logs" 
	// illustrative. in practice may be easier to directly reference paths

log using "$log_dir\comet_log.txt", text replace

// Importing, exporting data //
use "$data_dir\fake_data.dta", clear
save "$data_dir\edited_fake_data.dta", replace 
export delimited using "$data_dir\fake_data.csv", replace
import delimited using "$data_dir\fake_data.csv", clear // can also do excel

sysuse auto.dta, clear

// Getting to know the dataset //
describe price mpg // %>% select(price, mpg) %>% str() 
list price mpg in 1/3 // %>% select(price, mpg) %>% head(3)
codebook price mpg // similar to summarize but more info including missingness
tabulate foreign // shows n, n(%). can also use with 2 variables
lookfor weight // search for a variable, useful if there are many

// Investigate duplicates //
/*
duplicates tag id term, generate(dupes)
keep if dupes > 0
sort dupes id term
browse
*/

// Summary stats, ifs, operators //
summarize make mpg foreign if price > 5000 & (mpg <= 25 | gear_ratio > 3)
summarize price if !missing(rep78)
summarize price if rep78 != . // same thing since missing numerics are a blank
summarize price if make != "" // missing strings are empty strings

sort price // ascending order
summarize price in 1/10
list make price in -5/L // list 5 cars with highest price

// Local variables //
local i = 95
local course = "ECON 490"
display `i' // use backtick and apostrophe to reference local variables
display "`course'"
display "I am enrolled in `course' and hope my grade will be `i'%!"

// Loops //
forvalues i=30(5)50{ // for (i in seq(30,50,5)) { iterate over integers
	display `i'
}
foreach var in "mpg" "price"{ // iterate over a list of strings
    summarize `var'
}
local counter = 1 // while loop
while `counter'<5{
    display `counter'
    local counter = `counter'+1
}

forvalues i=1(1)23 {
	di `i'/23
}

// Storing results //
summarize price, detail
return list // returns local variables used to print output.
	// ereturn list for estimation commands

display r(mean)
local price_mean = r(mean)
display "The mean of the price variable is `price_mean'."

// Creating variables //
gen price_demean = price - `price_mean'
gen log_price = log(price)

gen origin = "domestic"
replace origin = "foreign" if foreign == 1 // %>% mutate(origin = if_else(...))

tabulate rep78, generate(rep)
	//tabulate rep78 and generate dummies for each level of rep78
describe rep* // describe all variables with name starting with rep

rename price_demean price_demeaned

// Dummy variables //
codebook origin
gen foreign_dummy = origin == "foreign"
fvset base 1 foreign_dummy // set reference level to 1

// Regression with dummy:
* reg logearnings i.region
	// put i. as a prefix, equivalent to as.factor(...)
* reghdfe logearnings age, absorb(region)
	// equivalent but works with many levels (High-Dimensional Fixed Effects)
	// suppresses coefficients for the many levels

// Labels //
label data "Auto data" // can check with describe that it changed
label variable price_demean "Demeaned Price"

label define foreignl 0 "domestic car" 1 "foreign car" 
	// create a value label foreignl that labels 1 as "foreign car"
label values foreign foreignl // associate foreign with the value label foreignl

quietly display "hello world" // suppress output

// Summarizing a variable based on its value of another variable //
levelsof rep78, local(levels_rep) 
	// define a new local variable levels_rep as the levels of rep78
foreach level in `levels_rep' {
	summarize price if rep78 == `level'
}

// Global variables //
global covariates "rep78 foreign"
su ${covariates}
global controls trunk foreign
reg price mpg $controls // curly brackets and quotations seem optional
foreach variable in $controls{ // another example.
    su `variable'
}

// Within group analysis //
// group by rep78 and make price_demeaned relative to the group (goofy way)
sort rep78
capture drop price_demeaned
by rep78:	summarize price // can also just do bysort rep78: ...
			return list
			local price_mean = r(mean)
			gen price_demeaned = price - `price_mean'
			
// better way with egen and bysort
bysort rep78: egen avg_price = mean(price)
bysort rep78 origin: egen tot_price = total(price)

egen sum_of_vars = rowtotal(weight length) // na.rm = T
* gen sum_of_vars = weight + length // na.rm = F, returns NA if there's NA's

// assign observation numbers by group
cap drop obs_number
bysort foreign: gen obs_number = _n
cap drop tot_obs
bysort foreign: gen tot_obs = _N
/*
for fake_data, can group by workerid, generate observation numbers by workerid,
and keep if tot_obs ==8 to only keep workers observed across all 8 periods
*/

// Reshaping/pivoting //
use "$data_dir\fake_data.dta", clear

reshape wide earnings region age start_year sample_weight quarter_birth, ///
	i(workerid) j(year)
	
reshape long earnings region age start_year sample_weight quarter_birth, ///
	i(workerid) j(year)
keep if !missing(earnings) // retrieve original dataset
	// reshape wide introduced NA's since workers only observed some years

// Merging and appending //
duplicates report workerid year

// Collapsing data //
* seems like %>% group_by(...) %>% summarize(...) ?
// create the macro-level dataset
gen log_earnings = log(earnings)
collapse (mean) avg_log_earnings = log_earnings ///
	(count) total_employment = log_earnings, by(region year)
label var avg_log_earnings "Average Log-earnings in Region-Year Cell"
save "$data_dir\region_year_data", replace

use "$data_dir\fake_data.dta", clear

cap drop _merge // good practice since merge creates a _merge variable
merge m:1 region year using "$data_dir\region_year_data.dta"
	// %>% left_join(region_year_data, by = c("region", "year"))
keep if _merge==3 // keep only obs correctly matched

* append using "$data_dir\data_to_append.dta" // appending

capture log close
