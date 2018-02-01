today's date is feb 1 
clear all
capture log close
*log using "Y:\Source_data\agincourt_hdss_nov_29_2017\data_checks.txt", text replace
log using "/Volumes/Projects/MHFUS/Source_data/agincourt_hdss_nov_29_2017/data_checks.txt", text replace

*PROGRAM: data_checks.do
*PURPOSE: completeness checks 
*INPUTS:  all data modules in batch received on Nov. 29th, 2017
*DATE:    12/29/2017

*set locals
*local dir "Y:\Source_data\agincourt_hdss_nov_29_2017"
local dir "/Volumes/Projects/MHFUS/Source_data/agincourt_hdss_nov_29_2017"

* print list of all data files: double check this matches the list of files on data extract request form
ls 

***Resident Status***
use "`dir'/10_ResidentStatus.dta", clear
rename *, lower

* check number of individuals looks right
bysort year: distinct id_anon
* if you sumup all the distinct individuals by year, shows accumulated over a million person-year records

* check distribution of year, resmonths, and resstatus
tab year
tab resstatus
sum resmonths, detail 



***Individual membership***
use "`dir'/01_Individual_Membership.dta", clear
rename *, lower
describe, fullnames

distinct village
distinct household_anon
* 31159 DOUBLE CHECK THIS SEEMS SENSIBLE 
distinct id_anon
* 258807
*(compared to the 2012 file has 198495) 

*years
gen styear = year(startdate) 
* WHY IS THERE A JUMP IN SOME YEARS??? 
gen endyear = year(enddate)

*proportion of people by number of records in the file 
preserve
	duplicates drop id_anon household_anon dob startdate enddate initiatingmeventtype terminatingmeventtype hhrelation, force
	bysort id_anon: gen rowcount = _n 
    collapse (count) numrec=rowcount, by(id_anon)
	tab numrec
restore

*proportion of people move to different households 
preserve
	bysort id_anon household_anon: gen flag = (_n == 1)
	collapse (sum) tothhmemberships=flag, by(id_anon)
	tab tothhmemberships
restore


***Labour Status***
use "`dir'/05_Labour_Status.dta", clear
rename *, lower

tab year
bysort year: distinct id_anon /*likely only done on working age individuals*/

tab everworked, m
tab currentlyworking, m
tab unemployment, m
tab pensionstudent, m
* the employment sector info is mostly missing can really only get indicator on whether currently working or not


***temp migrations *** 
use "`dir'/18_TemporaryMigrations.dta", clear
rename *, lower

tab year /*alos gives distinct migrants in each year*/

*how many records per migrant
bysort id_anon: gen migcount = _N
preserve
	bysort id_anon: keep if _n == 1
	tab migcount 
restore

tabmiss place1 
tabmiss town1

tab reason1 /*over 3 years, 72% mig went to look for work or for work*/
*job found variable really poor. 
*also nearly half missing/unknown on type of work

*examine return patterns 
destring(returnpattern), gen(returnpat) force
tabmiss returnpat
tab returnpat

*remittances
tab remittance
bysort year: tab childrenremain  /*around 30% leaving behind a child*/


***Individual Residence***
use "`dir'/02_Individual_Residences.dta", clear
rename *, lower

distinct id_anon 
distinct village 

*years
gen styear = year(startdate) /*why jump in some years? when new village added?*/
gen endyear = year(enddate)


***Inmigration ***
use "`dir'/03_InMigration.dta", clear
rename *, lower

distinct id_anon 
tab moveinyear 
tabmiss reason 
tab reason 


***Outmigration ***
use "`dir'/04_OutMigration.dta", clear
rename *, lower

distinct id_anon 
tab moveoutyear 
tab reason 


*** 06_AssetStatus.dta *** ARE WE MISSING HOUSEHOLDS IN EACH YEAR?
use "`dir'/06_AssetStatus.dta", clear
rename *, lower
bysort year: distinct household_anon 


*** SES **
use "`dir'/07_SESIndices.dta", clear
rename *, lower
tab year

tabmiss ses_dwelling
tabmiss sesabs


*** food security *** 
use "`dir'/08_FoodSecurity_Status.dta", clear
rename *, lower
tab year 

bysort year: distinct household_anon 


*** Education *** 
use "`dir'/09_EducationStatus.dta", clear
rename *, lower
bysort year: distinct id_anon
tab education 
*later years are very complete. can infer backwards educational status


*** Individual grant status (only for women who gave birth) *** 
use "`dir'/11_IndividualGrantStatus.dta", clear
rename *, lower 
tab year 


*** Adult health status *** 
use "`dir'/12_AdultHealthStatus.dta", clear
rename *, lower
tab year
*ONLY HAVE THIS FOR 2010


*** temporary migration children *** 
use "`dir'/19_TMChildren.dta", clear
rename *, lower
bysort year: distinct id_anon

**THE WHO CARES FOR CHILD VARIALBE IS NOT ANONYMIZED SO I CAN'T LINK IT


*** birth/ pregnancies *** 
use "`dir'/13_Birth_Pregnancies.dta", clear
 distinct MotherId_Anon

 
*** deaths *** 
use "`dir'/14_Deaths.dta", clear
rename *, lower 
tab year
distinct id_anon


*** fieldworkers *** 
use "`dir'/15_Fieldworkers.dta", clear
distinct Fieldworker_Anon


*** child grants MISSING MANY VARIABLES*** 
use "`dir'/16_ChildGrantX.dta", clear
rename *, lower
tab year


*** maternity history *** 
use "`dir'/17_MaternityHistory.dta", clear
rename *, lower
tab year 
distinct id_anon 


*** father support and fatherhood *** 
use "`dir'/20_FatherSupport_and_FatherHood.dta", clear
rename *, lower
tab obsyear
*ONLY ONE YEAR OF DATA

log close
