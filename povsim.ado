*! Version 1.0.0  <28Sep2016>    
*! Author: Santiago Garriga   -- garrigasantiago@gmail.com

/* *===========================================================================
	POVsim: Growth Incidence Curve Simulation
	Reference: 
-------------------------------------------------------------------
Created: 		11 May2016	 
Modified:		
Version:		01 
Dependencies: 	
*===========================================================================*/

cap program drop povsim
program define povsim, rclass

	syntax varname(numeric)					 			///
		[fweight aweight iweight],						///
		gic(name)										/// Growth incidence curve: linear, convex, step and empirical 
		growth(numlist >=-7.5  <=7.5)									/// Mean annual growth rate of entire distribution or growth per repetititon
		REPetitions(numlist max=1 >0 <=50 integer)		/// Numbers of periods (years) to repeat the simulation.
		[												///
		premium(numlist max=1 >=-7.5 <=7.5)					/// Growth premium (M) – the gap in growth rate between bottom X and the mean 
		gini(numlist max=1)								/// gini change
		PASSthrough(numlist max=1 >0  <=2)				/// Passthrough
		bottom(numlist max=1 >=10 <=70 integer)			/// Bottom X % for which mean growth rate should be m larger than g
		obs(numlist max=1 >=100 <=100000 integer)		///	Either expansion of observations (under ungroup option) or group them
		varmean(varname numeric)						/// Welfare's mean variable
		poverty(string)									/// Estimate poverty figures and save them in "string" name
		line(numlist >0)								/// Poverty line for poverty figures
		adjustp(numlist max=1 >=0 <=100 integer)		/// adjustment of m due to re-ranking	
		name(string)									/// Name of the file to be exported
		folder(string)									/// Folder to export "generated" data
		replace											/// Replace existing dataset
		]

qui{
preserve

* ==================================================================================================
* =========================================1.Error Messages======================================== 
* ==================================================================================================


* GIC type
if "`gic'" != "l" & "`gic'" != "c" & "`gic'" != "s" & "`gic'" != "e" {
	disp in red "You should specify either l (linear), c (convex), s (step function) or e (empirical)"
	error
}


* Data to feed empirical estimation is mandatory
if ("`gic'" == "e") & "`efile'" == "" {
	disp in red "You should specify an efile to feed the empirical estimation."
	error
}

* Poverty and line should be specified at the same time
if ("`poverty'" != "" & "`line'" == "") | ("`poverty'" == "" & "`line'" != "") {
	disp in red "You should specify both, poverty and line."
	error
}

* growth vector N itemes != repetitions
if wordcount("`growth'") > 1 {
	noi di as result "Growth is a vector"
	if wordcount("`growth'") != `repetitions'{
		noi di as error "The growth vector must have the same number of entries as the number of repetitions"
		error
	}
}


* ==================================================================================================
* =========================================2. Set Default Options=================================== 
* ==================================================================================================

// We only allow for type welfare
local welfare "`varlist'"
local varlist ""

* Type Empirical
if "`gic'" == "e" {
	cap confirm file `"`efile'"'
	if _rc != 0 {
		disp in red "efile does not exist"
		error	
	}
	if _rc == 0 {
		cap d pctl pr_growth using `"`efile'"', simple
		if _rc != 0 {	
			disp in red "either pctl or pr_growth do not exist in efile"
			error	
		}
		if _rc == 0  local eobs `r(N)'
		noi dis `eobs'
	}
	
}

* Type Ungroup
if "`ungroup'" == "" {
	cap which ungroup
	if _rc != 0 {
		cap window stopbox rusure "Advice" ///
			"You have chosen to ungroup without having the command. Do you allow us to download it from the web?" ///
				 "Click on Yes if you agree."
		if (_rc == 1) {
			disp in red "You need ungroup command to run this script"
			error
		}
		if (_rc == 0) {
			net from http://dasp.ecn.ulaval.ca/modules/DASP_V2.3/dasp
			net install dasp_p4, force
		}
	}
}

* Weight
if "`weight'" != "" {
	local peso: subinstr local exp "=" ""
	local weight `"[`weight' `exp']"'
}

* Bottom
if ("`bottom'" == "") local bottom = 40


* Expansion or group factor
count
if ("`obs'" == ""){
	local expansion = `r(N)'
}

if ("`obs'" != ""){
	if (`obs' > `r(N)' & "`ungroup'" == "") | (`obs' < `r(N)' & "`ungroup'" != "")  local expansion = `r(N)'
	else local expansion = `obs'
}

* Mean
if "`varmean'" != "" {
	sum `varmean'
	local mean `r(mean)'
}

* Folder
if (`"`folder'"' != `""') {
	if regexm(`"`folder'"', `"[\]$"') ///
		local folder = reverse(substr(reverse(`"`folder'"'), 2, .))
	if regexm(`"`folder'"', `"[a-zA-Z0-9]$"') local folder "`folder'/"
}

if (`"`folder'"' == `""') 	local folder "`c(pwd)'"

* Name
* if ("`name'" == "") {
	* local name: dis %tdDDMonCCYY date(c(current_date), "DMY")
	* local name povsim`name'
* }

* Adjust option
if ("`adjustp'" == "") local adjustp = 0


// default of passthrough
loc growth0 "`growth'"	// store the original growth vector
if ("`passthrough'" == "") loc passthrough = 1


// Addjust growth if vector & adjust growth by passthrough 
loc j = 0
foreach grw in `growth' {
	loc ++j
	loc growth`j' = `grw' * `passthrough'
	loc growthnew "`growthnew' `growth`j''"
}

loc grw_lvl = `j' // store the number of growth values
loc j 

* Keep relevant vars
keep `welfare' `peso' `varmean' 

/* -------------------------------------------------------------------------------------------------
										Variable Creation
--------------------------------------------------------------------------------------------------*/ 		

tempvar welfarenew /*welfare*/ sharenew /*Welfare's share*/ ftile /* Fractile*/ sharecumnew /*Accumulated Share*/ tiles
tempfile disaggregation 


gen `welfarenew' = `welfare'

* Erase missing values
drop if `welfarenew' == .

* Count # of zero
count if `welfarenew' == 0
if `r(N)' > 0 dis in r "There are `r(N)' observations with zero `welfare'"

* Count # of negative
count if `welfarenew' < 0
if `r(N)' > 0 dis in r "There are `r(N)' observations with negative `welfare'"

* Gen Welfare's share
sum `welfarenew' `weight'
local mean `r(mean)'

if ("`ungroup'" != "") {									// Option to generate share without generating deciles
	local sum `r(sum)'
	gen `sharenew' = `welfarenew'/`sum'
}

if ("`ungroup'" == "") {									// Option to generate share generating Fractiles	
	sort `welfarenew'
	
	* Sum weights
	if "`peso'"!= "" gen shrpop = sum(`peso')
	if "`peso'"== "" gen shrpop = _n
	
	if "`obs'"== "" {
		gen `ftile' = _n									// if observation is not specified each obs is a fractile group
		sum `welfarenew'
		local sum `r(sum)'
		gen `sharenew' = `welfarenew'/`sum'				
		
		if "`peso'"!= "" {
			replace `ftile' = shrpop/shrpop[_N]	
			gen toerase = `welfarenew'*`peso'
			sum `welfarenew' `weight'
			local sum `r(sum)'
			replace `sharenew' = toerase/`sum'	
			
		}
	}
	if "`obs'"!= "" {
		replace shrpop = shrpop/shrpop[_N]

		* Identify fractile of welfare
		gen `ftile' = .
		forvalues j = 1(1)`expansion' {
			replace `ftile' = `j' if shrpop > (`j'-1)*(1/`expansion') & shrpop <= `j'*(1/`expansion')
		} 
		collapse (mean)`welfarenew' `weight', by(`ftile') 	// Generate average income by Fractile
	
		sum `welfarenew'
		local sum `r(sum)'
		gen `sharenew' = `welfarenew'/`sum'
	}
}

		
* Generate fractile
sort `welfarenew'
count
local obse `r(N)'


* Ungroup condition
if "`ungroup'" == "" {
	gen meanM0 =  `welfarenew'
	sort meanM0
	gen mtile0 = _n																	

}

if "`ungroup'" != "" {											// Disaggregation of aggregated data
	gen `ftile' = _n/`obse'
	ungroup `ftile' `sharecumnew', fname(`disaggregation') nobs(`expansion') dist(lnorm)

	use `disaggregation', clear
	sort _y
	count
	local obse `r(N)'
	gen mtile0 = _n
	ren _y share
	replace share = share/`obse'								// Change compared to povcal version
	
	gen meanM0 = `obse' * share * `mean'		
	keep mtile0 meanM0
}
if "`obs'" == "" & "`weight'"!= "" keep meanM0 mtile0 `peso'
else {
	keep meanM0 mtile0
	local weight "" 
}
order meanM0 mtile0
	

* ==================================================================================================
* =========================================3. Run sub-programs======================================
* ==================================================================================================


/*===========================================================================
							3.1 Linear GIC									
===========================================================================*/

if ("`gic'" == "l") {
	povsim_linear, growth(`growthnew') premium(`premium') bottom(`bottom') repetitions(`repetitions') weight(`weight') peso(`peso') folder(`folder') name(`name') adjustp(`adjustp') `replace'
}

/*===========================================================================
							3.2 Convex GIC									
===========================================================================*/
if ("`gic'" == "c") {
	povsim_convex, growth(`growthnew') premium(`premium') gini(`gini') bottom(`bottom') repetitions(`repetitions') weight(`weight') peso(`peso') folder(`folder') name(`name') adjustp(`adjustp') `replace'
}

/*===========================================================================
							3.3 Step Function GIC						
===========================================================================*/
if ("`gic'" == "s") {
	povsim_sfunction, growth(`growthnew') premium(`premium') bottom(`bottom') repetitions(`repetitions') weight(`weight') peso(`peso') folder(`folder') name(`name') adjustp(`adjustp')`replace'
}

/*===========================================================================
							3.4 Empirical GIC									
===========================================================================*/
* if ("`gic'" == "e") {
	* povsim_empirical, growth(`growth') premium(`premium') bottom(`bottom') repetitions(`repetitions') folder(`folder') name(`name') `replace' efile(`efile') eobs(`eobs')
* }

/* -------------------------------------------------------------------------------------------------
										Auxiliary Estimations
--------------------------------------------------------------------------------------------------*/ 

*----------------------------------------- Poverty -------------------------------------------------
if "`poverty'" !=  "" {

	tempfile presults
	tempname p 
	postfile `p' double (period line headcount) using `presults', replace // Results

	local lines "`line'"
	local a = 0
	foreach line of local lines {
		local ++a
		foreach n of numlist 0(1)`repetitions' {	
			apoverty meanM`n' `weight', line(`line')
			if `n' == 0 local basepov_`a' `r(head_1)'				// Baseline poverty
			if `n' == `repetitions' local finalpov_`a' `r(head_1)'	// Final poverty
			post `p' (`n') (`line') (`r(head_1)') 
		}		
	}
	postclose `p'
	use `presults', clear
	compress
	save "`folder'\\`poverty'.dta", `replace'
}



* ==================================================================================================
* =========================================4. Display Information===================================
* ==================================================================================================
/*
if "`gic'" == "l" local type "Linear"
if "`gic'" == "c" local type "Convex"
if "`gic'" == "s" local type "Step Function"
if "`gic'" == "e" local type "Empirical"

* Display information
noi dis as text "{hline}" 
noi dis as text "{p 4 4 2}{cmd:The following is the information of the Simulation: POVSIM} " in y "`countryname'" as text " {p_end}"
noi dis as text "{hline 60}"

noi di as text _new  "Growth Incidence Curve: {cmd: `type'}"
if ("`varlist'" != "") noi di as text _new  "Welfare variable: {cmd: `varlist'}"
noi di as text _new  "Bottom group: {cmd: `bottom'(%)}"
noi di as text _new  "Growth: {cmd: `growth'}"
noi di as text _new  "Growth premium: {cmd: `premium'}"
noi di as text _new  "Repetitions: {cmd: `repetitions'}"
if "`poverty'" !=  "" {
	local a = 0
	foreach line of local lines {
		local ++a
		noi di as text _new  "Baseline poverty(`line'):" in w %6.2f `basepov_`a''
		noi di as text _new  "Final poverty(`line'):" in w %6.2f `finalpov_`a''
	}
}
if "`name'" !=  "" noi di as text _new  "Name of simulated data: {cmd: `name'} " `"{browse "`folder'\\`name'.dta":{space 5}Open }"'
if "`poverty'" !=  "" noi di as text _new  "Name of poverty data: {cmd: `poverty'} " `"{browse "`folder'\\`poverty'.dta":{space 5}Open }"'
if "`name'" !=  "" | "`poverty'" !=  "" noi di as text _new  "Path: {cmd: `folder'}" 

loc j = 0
foreach grwth in `growthnew' {
	loc ++j
		if abs(`premium' - $g40fi+`grwth' )>0.01 noi di in red "Warning: the difference between the desired premium and the simulated one is greater than 0.01 for growth item `j' "
		noi di as text "{hline 5}{c +}{hline 55}"	
}

* Return information
if "`poverty'" !=  "" {
	local ++a
	foreach line of local lines {
		local --a
		return scalar finalpov_`a' = `finalpov_`a''
		return scalar basepov_`a' = `basepov_`a''
	}
}

loc j = 0
foreach grwth in `growthnew' {
	loc ++j
	local premium_actual`j' : display %5.4f $g40fi-`grwth' 	                
	return scalar premium_actual`j' = `premium_actual`j''	
	return scalar growth`j' = `grwth'
}

local bfi : display %5.4f $g40fi 
local tfi : display %5.4f $g60fi 

local top = 100 - `bottom'  
return scalar gbottomfi = `bfi'               
return scalar gtopfi = `tfi'            
return scalar repetitions = `repetitions'
return scalar premium = `premium'
return scalar bottom = `bottom'
*/
restore
}
		
end

exit 
----------------------------------------------------------------------------------------------------

Notes:
1.
2.
3.
.....

Version Control:
