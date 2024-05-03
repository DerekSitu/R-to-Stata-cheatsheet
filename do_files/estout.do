capture log close
clear *

capture cd "C:\Users\dsder\OneDrive\Desktop\RA\COMET"
capture cd "C:\Users\situ_\OneDrive\Desktop\RA\COMET"

log using ".\logs\estout_log.txt", text replace

* Following along https://libguides.library.nd.edu/data-analysis-stata/tables

sysuse nlsw88, clear

tabulate race, gen(dum_race) // make dummies for each category of race

// Make simple table
estpost summarize age wage dum_race1 dum_race2 dum_race3 collgrad
eststo summstats
esttab summstats using ".\tables\table1.rtf", replace main(mean %6.2f) ///
	aux(sd) label
esttab summstats using ".\tables\table1.tex", replace main(mean %6.2f) ///
	aux(sd) label

// Add columns for subsamples
eststo grad: estpost summarize age wage dum_race1 dum_race2 dum_race3 ///
	if collgrad==1
eststo nograd: estpost summarize age wage dum_race1 dum_race2 dum_race3 ///
	if collgrad==0
esttab summstats grad nograd using ".\tables\table2.rtf", replace ///
	main(mean %6.2f) aux(sd) ///
	mtitle("Full sample" "College graduates" "Non-college graduates") ///
	coeflabel(dum_race1 "White" dum_race2 "Black" dum_race3 "Other" age ///
			  "Age" wage "Hourly wage" collgrad "College graduate") ///
	title(Table 2. Summary Statistics, NLSW88) ///
	nogaps compress refcat(dum_race1 "Race:", nolabel)
esttab summstats grad nograd using ".\tables\table2.tex", replace ///
	main(mean %6.2f) aux(sd) ///
	mtitle("Full sample" "College graduates" "Non-college graduates") ///
	coeflabel(dum_race1 "White" dum_race2 "Black" dum_race3 "Other" age ///
			  "Age" wage "Hourly wage" collgrad "College graduate") ///
	title(Table 2. Summary Statistics, NLSW88) ///
	nogaps compress refcat(dum_race1 "Race:", nolabel)
	
// Add column for t-test of difference between subsamples
eststo groupdiff: estpost ttest age wage dum_race1 dum_race2 dum_race3, ///
	by(collgrad)

esttab summstats grad nograd groupdiff using ".\tables\table3.rtf", replace ///
	main(mean %6.2f) aux(sd) ///
	mtitle("Full sample" "College graduates" "Non-college graduates" "Difference (3)-(2)") ///
	nogaps compress refcat(dum_race1 "Race:", nolabel) ///
	coeflabel(dum_race1 "White" dum_race2 "Black" dum_race3 "Other" age ///
			  "Age" wage "Hourly wage" collgrad "College graduate") ///
	title(Table 3. Summary Statistics, NLSW88)
esttab summstats grad nograd groupdiff using ".\tables\table3.tex", replace ///
	cell("mean(pattern(1 1 1 0) fmt(2)) b(pattern(0 0 0 1) fmt(2)) se(pattern(0 0 0 1) fmt(2))") ///
	mtitle("Full sample" "College graduates" "Non-college graduates" "Difference (3)-(2)") ///
	nogaps compress refcat(dum_race1 "Race:", nolabel) ///
	coeflabel(dum_race1 "White" dum_race2 "Black" dum_race3 "Other" age ///
			  "Age" wage "Hourly wage" collgrad "College graduate") ///
	title(Table 3. Summary Statistics, NLSW88)


capture log close
