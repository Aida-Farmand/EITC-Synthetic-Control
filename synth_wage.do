clear
//net install load_epiextracts, from("https://microdata.epi.org/stata")

load_epiextracts, begin(1984m1) end(2019m12) keep(age wbho emp educ year month wage statefip married unempdur ownchild female) sample(org) sourcedir("/Users/aida/Downloads/epi_cpsorg")

gen black=0
replace black=1 if wbho==2
gen agecat=1 if age <=54
replace agecat=2 if age>54
gen educat=0
replace educat=1 if (educ<4)
replace educat=2 if (educ>=4)
summ unempdur
bys statefip year: egen unemp= mean (unempdur) 
replace wage= wage*248.804/251.712 if year == 2019
replace wage= wage*248.804/248.804 if year == 2018
replace wage= wage*248.804/243.414 if year == 2017
replace wage= wage*248.804/237.387 if year == 2016
replace wage= wage*248.804/234.849 if year == 2015
replace wage= wage*248.804/234.996 if year == 2014
replace wage= wage*248.804/231.739 if year == 2013
replace wage= wage*248.804/227.907 if year == 2012
replace wage= wage*248.804/221.666 if year == 2011
replace wage= wage*248.804/217.020 if year == 2010
replace wage= wage*248.804/212.015 if year == 2009
replace wage= wage*248.804/212.100 if year == 2008
replace wage= wage*248.804/203.756 if year == 2007
replace wage= wage*248.804/198.933 if year == 2006
replace wage= wage*248.804/191.933 if year == 2005
replace wage= wage*248.804/186.3 if year == 2004
replace wage= wage*248.804/183 if year == 2003
replace wage= wage*248.804/177.9 if year == 2002
replace wage= wage*248.804/175.7 if year == 2001
replace wage= wage*248.804/169.9 if year == 2000
replace wage= wage*248.804/164.6 if year == 1999
replace wage= wage*248.804/161.9 if year == 1998
replace wage= wage*248.804/159.6 if year == 1997
replace wage= wage*248.804/155 if year == 1996
replace wage= wage*248.804/150.9 if year == 1995
replace wage= wage*248.804/146.7 if year == 1994
replace wage= wage*248.804/143.1 if year == 1993
replace wage= wage*248.804/138.7 if year == 1992
replace wage= wage*248.804/134.8 if year == 1991 
replace wage= wage*(1.91) if year == 1990
replace wage= wage*248.804/124 if year == 1989
replace wage= wage*248.804/118.3 if year == 1988
replace wage= wage*248.804/113.6 if year == 1987
replace wage= wage*248.804/109.6 if year == 1986
replace wage= wage*248.804/107.6 if year == 1985
replace wage= wage*248.804/103.9 if year == 1984
drop if wage<1
gen lnwage2= ln(wage)
//keep if (female==1 & age>24 & age<51 & educat <=3 & married==0 & ownchild>0 & year>1999)
keep if (age>54 & educat <=3)

gen qdate = qofd(dofm(ym(year, month)))
//format %tq date
//collapse (sum) outpatient (sum) admissions, by(hospital qdate) 

//bys qdate statefip: egen total_empl = count(emp) if (emp==1)

//gen modate = ym(year, month)
//tab modate if year==1996
//gen date = year+month*10
tab qdate if year==2017
//format modate %tm
preserve
//collapse wage unemp emp [pw=orgwgt] if (female==1 & age>24 & age<35 & educat <=3 & ownchild>0 & married==0), by(statefip modate)
//collapse wage unemp [pw=orgwgt] if (age>54 & educat <=3), by(statefip modate)



collapse lnwage2 wage unemp [pw=orgwgt/12] if (age>54 & educat <=3), by(statefip qdate)


tsset statefip qdate

gen byte d = (statefip==6 & qdate>=224)|(statefip==36 & qdate>=144)|(statefip==9 & qdate>=204)|(statefip==11 & qdate>=164)|(statefip==24 & qdate>=176)|(statefip==25 & qdate>=224)| (statefip==27 & qdate>=148)|(statefip==34 & qdate>=172)|(statefip==50 & qdate>=112)

synth_runner emp emp(96(1)112), d(d) trends training_propr(`=10/12') 
effect_graphs
pval_graphs





//drop if qdate<180
//gen byte p = (statefip==9 & qdate>=204)

synth_runner lnwage2 lnwage2(96(1)112), d(p) trends training_propr(`=10/12') gen_vars
effect_graphs
pval_graphs





*gen byte d = (statefip==6 & modate>=672)|(statefip==36 & modate>=432)|(statefip==9 & modate>=612)|(statefip==11 & modate>=492)|(statefip==24 & modate>=528)|(statefip==25 & modate>=672)| (statefip==27 & modate>=444)|(statefip==34 & modate>=516)|(statefip==50 & modate>=336

synth_runner emp emp(400(1)431), d(d) trends 

synth_runner wage wage(288(1)431) mw gdp_real, d(p) trends gen_vars
synth_runner wage wage(288(1)431) mw gdp_real unemp, d(p) trends pre_limit_mult(1) training_propr(`=10/12')
synth_runner wage, d(p) trends pre_limit_mult(10) training_propr(`=130/144') gen_vars
synth_runner emp emp(233(1)431), d(d) trends 





