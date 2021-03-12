/* *===========================================================================
	Convex do (povsim): Derivation of the convex GIC 
	Reference: 
-------------------------------------------------------------------
Created: 		26May2016	( & ) 
Modified:		
version:		
Dependencies: 	
*===========================================================================*/

cap program drop povsim_convex
program define povsim_convex, rclass

	syntax [anything]									///
		,												///
		[												///
		weight(string)									/// Weight
		peso(string)									///
		growth(numlist)									/// Mean annual growth rate of entire distribution
		premium(numlist)								/// Growth premium (M) – the gap in growth rate between bottom X and the mean 
		bottom(numlist)									/// Bottom X % for which mean growth rate should be m larger than g, by default 
		repetitions(numlist)							/// Numbers of periods (years) to repeat the simulation.
		folder(string)									/// Folder to export "generated" data
		name(string)									/// Name of the file to be exported
		adjustp(numlist max=1 >=0 integer)				/// adjustment of m due to re-ranking	
		replace											///
		]
qui{
* Locals
local gap = 0.02					// starting value for the loop; could be anything? 
local top = 100 - `bottom'
count
local obs `r(N)'
local dpremium = `premium'
local bottom = (`bottom'/100)

if "`weight'" != "" {
	sort meanM0
	gen shrpop0 = sum(`peso')
	replace shrpop0 = shrpop0/shrpop0[_N]	
}
else gen shrpop0 = mtile0/`obs'



* Tempfile for loop
tempfile temp
save `temp', replace

local round = -1

while `gap' > 0.0001 & `round'< `adjustp' {
	
	local ++round
	use `temp', replace
	
	foreach n of numlist 1(1)`repetitions' {	
		local last = `n' - 1
		
		* Share of Bottom
		sum meanM`last' `weight'
		global yi_sum = r(sum)				// Overall sum
		global yi_mean = r(mean)			// Overall mean
		
		sum meanM`last'	`weight' if shrpop`last' <= `bottom'
		global yi_sum_bottom = r(sum)		// Bottom sum
		
		* Generate Alpha
		global alpha = `premium' /((1 + `growth')*(((100*`bottom'*$yi_sum)/(100 * $yi_sum_bottom))-1))
		
		*Generate new incomes:
		gen meanM`n'=(1 + `growth')*(((1 - $alpha) * meanM`last' )+ ($alpha * $yi_mean))
		
		*New shares
		* gen share=meanM`n'/(10000*mean*((1+ghist)^`n'))

		*Re-rank: 
		sort meanM`n'
		gen mtile`n'=_n
		
		if "`weight'" != "" {
			sort meanM`n'
			gen shrpop`n' = sum(`peso')
			replace shrpop`n' = shrpop`n'/shrpop`n'[_N]	
		}
		else gen shrpop`n' = mtile`n'/`obs'
	}
		
	*Generate average growth rates: 
	*Bottom X% 
	sum meanM0 `weight'	if shrpop0 <= `bottom'
	global mean40_0 = r(mean)
	
	sum meanM`repetitions' `weight' if shrpop`repetitions' <= `bottom'
	global mean40_19 = r(mean)
	global g40fi = ($mean40_19/$mean40_0)^(1/`repetitions') -1
	
	*Top X%
	sum meanM0 `weight' if shrpop0 > `bottom' & !mi(shrpop0)
	global mean60_0 = r(mean)
	
	sum meanM`repetitions' `weight' if shrpop`repetitions' > `bottom' & !mi(shrpop`repetitions')
	global mean60_19 = r(mean)
	global g60fi=($mean60_19/$mean60_0)^(1/`repetitions') -1
	
	*Actual m
	global b = $g40fi- `growth'
	
	*Adjust the m as a function of the gap: 
	*The loop runs as long as the gap is > 0.0001=0.01%
	local gap`round' = `gap'
	local gap = `dpremium' - $b

	*Adjust the m as a function of the gap: 	
	if `adjustp' > 0 {
		if `round'>0 {
			if `gap`round'' >= `gap' local premium = `premium'+2*`gap'
			
			if `gap`round'' < `gap' local premium = `premium'-2*`gap'
			
		}
		if `round' == 0 local premium = `premium'+`gap'
	}
}

drop shrpop*
local bottom = 100 - `top'
gen premium = `premium'
gen g`bottom'fi = $g40fi
gen g`top'fi = $g60fi


* Export data
if "`name'"!="" {
	rename meanM* welfare*
	compress
	save "`folder'\\`name'.dta", `replace'
	rename welfare* meanM*
}
}
end 
exit
