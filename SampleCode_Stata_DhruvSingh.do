set more off
clear


// Template code required for running code on grader's machine

if c(username)=="jlindo" {
    cd "/Users/jlindo/Dropbox/Teaching/Program Evaluation/Program Evaluation Assignments/Spring 2017"
}
 if c(username)=="yanxueqing" {
	cd "C:\Users\yanxueqing\Desktop\Program evaluation\Assignments"
}

cap cd "H:\Spring 2017 TAMU\ECON 470\Assignment1Files\Assignment 1"

// Assignment code

* Log file
log using Assignment4_log, replace

* Reading in Data
use stardata_Kindergarten, clear

* Creating percentiles of test scores (using only reg and reg+aide classes), apply percentiles to entire sample to create mean score
replace readk=. if readk==999
replace mathk=. if mathk==999
pctile readkpct=readk if ctypek==2|ctypek==3, nq(100)
pctile mathkpct=mathk if ctypek==2|ctypek==3, nq(100)
xtile readkperc=readk if ctypek~=9, cutpoints(readkpct)
xtile mathkperc=mathk if ctypek~=9, cutpoints(mathkpct)
gen mnscorek=(readkperc+mathkperc)/2
replace mnscorek=readkperc if mathkperc==.
replace mnscorek=mathkperc if readkperc==.
label var mnscorek "mean reading and math score, grade k"

* Creating age variable, year of birth, quarter of birth, month of birth
replace yob=. if yob==9999
replace qob=. if qob==99

gen mob=.
replace mob=2.5 if qob==1
replace mob=5.5 if qob==2
replace mob=8.5 if qob==3
replace mob=11.5 if qob==4 
gen agein1985=1985-yob+(9-mob)/12 
label var agein1985 "Age in (September) 1985"

* Generating indicator var for free/reduced price lunch
replace sesk=. if sesk==9
gen freelunch=1 if sesk==1
replace freelunch=0 if sesk==2

* Generating indicator for white or asian student
replace race=. if race==9
gen white_asian=1 if race==1|race==3
replace white_asian=0 if race==2|race==4|race==5|race==6

* Generating indicator for white or asian teacher
replace tracek=. if tracek==9
gen white_asian_teacher=1 if tracek==1|tracek==3
replace white_asian_teacher=0 if tracek==2|tracek==4|tracek==5|tracek==6

* Modifying totexpk
replace totexpk=. if totexpk==99
 
/* PART 2 */

* 2.a
* Generating indicator for small class type
replace ctypek=. if ctypek==9
gen small=1 if ctypek==1
replace small=0 if ctypek==2|ctypek==3

* Indicator for reg+aide class
gen regaide=1 if ctypek==3
replace regaide=0 if ctypek==1|ctypek==2

* 2.c
* Running robust regressions to test for impact of small, regaide class type on characteristics.
* The following 3 indicator dependent vars are regressed on independent 2 ones
reg freelunch small regaide, robust
reg white_asian small regaide, robust
reg white_asian_teacher small regaide, robust

* Following 2 dependent non-indicator vars are regressed on independent vars
reg agein1985 small regaide, robust
reg totexp small regaide, robust

* 2.e 
* Creating indicator for regular class
gen regular=1 if ctypek==2
replace regular=0 if ctypek==1|ctypek==3

/* To test for significant difference between small and reg+aide class types, we
run regressions, first controlling for regular, while omitting reg+aide.
the beta coefficient's significance will determine the answer */
reg freelunch small regular, robust
reg white_asian small regular, robust
reg white_asian_teacher small regular, robust
reg agein1985 small regular, robust
reg totexp small regular, robust

* Next, we control for regular, while omitting small from our regressions.
reg freelunch regular regaide, robust
reg white_asian regular regaide, robust
reg white_asian_teacher regular regaide, robust
reg agein1985 regular regaide, robust
reg totexp regular regaide, robust

* 2.f
xi i.schidk, noomit

* For all 5 characteristics
reg freelunch small regaide i.schidk, robust
reg white_asian small regaide i.schidk, robust
reg white_asian_teacher small regaide i.schidk, robust
reg agein1985 small regaide i.schidk, robust
reg totexp small regaide i.schidk, robust

* Noe: some difference in coefficients is seen

/* PART 3*/

* 3.a

* Regression showing effect of assignment to different class types on test scores
reg mnscorek small regaide i.schidk, robust 

* 3.b

* Regression showing effect of being in small classes on test scores 
reg mnscorek small i.schidk, robust

* 3.c

* Regression showing effect on class size of being assigned to small class size 
reg csizek small i.schidk, robust

/* PART 4*/

* 4.b

* Regressions from ASSIGNMENT 3 parts b & c
reg mnscorek small i.schidk, robust

reg csizek small i.schidk, robust

* 4.d

ivregress 2sls mnscorek i.schidk (csizek = small), robust

* 4.e

ivregress 2sls mnscorek race sesk yob i.schidk (csizek = small), robust

log close
