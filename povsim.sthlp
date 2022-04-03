{smcl}
{* 04Oct2016 }{...}
{cmd:help for povsim }{hline 1} 
{hline}

{title:Title}

{phang}
{bf:povsim} {hline 2} A Stata command for simulating changes in welfare distributions and poverty.  


{* SYNTAX *}
{title:Syntax}

{p 6 16 2}
{cmd:povsim} {it:varname [weights]{cmd:,}} {it:{help povsim##options:Options}}
 

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help povsim##desc:Command description}}
		{it:{help povsim##Options2:Options description}}
		{it:{help povsim##Examples:Examples}}

{marker options}{...}
{synoptset 30 tabbed}{...}
{synopthdr:Options}
{synoptline}

{syntab:{help povsim##mandatory:Mandatory}}

{synopt:{opt gic(l|c)}} Growth incidence curve: linear{it:(l)} or convex{it:(c)}.{p_end}

{synopt:{opt growth(numlist)}} Growth in the mean of the entire distribution. Could be a vector of growth rates of the same lenght as the number of repetitions.{p_end}

{synopt:{opt premium(numlist)}} Growth premium, the percentage point (pp) difference in the growth rate between the poorest {it:X%} given in {it:bottom()} and the growth rate of the overall mean.{p_end}

{synopt:{opt gini(numlist)}} Growth in gini. should not be combined with {opt premium}.{p_end}

{synopt:{opt repetitions(numlist)}} Number of periods (e.g. {it:years}) to repeat the simulation.{p_end}

{syntab:{help povsim##optional:Optional}}

{synopt:{opt pass:through(numlist)}} Passthrough rate i.e. the share of growth observed in national accounts that gets reflected in household level data. The acceptable range is >0 and <=2.{p_end}

{synopt:{opt bottom(numlist)}} Bottom {it:X%} group to which the growth premium {it:(premium)} should be applied. Default is bottom 40%.{p_end}

{synopt:{opt varmean(numlist)}} Specify variable containing mean of welfare distribution ({it:varname}) for data types {it:share} or {it:sharecum}. {p_end} 

{synopt:{opt poverty(string)}} Estimate poverty headcount rate for each period of simulated data. {it:String} contains the file name with resulting poverty estimates.{p_end}

{synopt:{opt lines(numlist)}} Specify the poverty lines to be used in the poverty estimates. Multiple poverty lines are allowed.{p_end}

{synopt:{opt adjustp(numlist)}} Specify number of attempts to adjust {it:premium} so that final annualized growth premium achieved after re-ranking of the distribution equals the {it:premium} set for the simulation. Default is no adjustment 
{it:adjustp(0)}. {p_end}

{syntab:{help povsim##export:Export}}

{synopt:{opt name(string)}} File name for simulated distributional data. {p_end}

{synopt:{opt folder(string)}} Directory for storing simulated distributional and poverty data.{p_end}

{synopt:{opt replace}} Replace existing output with same file name.{p_end}

{marker desc}{...}
{title:Description}

{pstd}
{cmd:povsim} is a command for simulating changes in welfare distributions and poverty, following the approach proposed by Lakner, Negre, and Prydz (2014). Users should begin with a dataset containing a distributional variable (e.g. per capita 
consumption or income share) specified in {it:varname}. The user specifies the growth rate of the overall distribution ({it:growth}) and the growth incidence (distribution of growth) by choosing a growth incidence curve ({it:gic}) and a growth 
premium ({it:premium}) for the poorest X%. Users also need to specify the number of iterations for the simulation. After the output is generated a link is provided to the simulated data. When specified, poverty headcount rates are estimated using the 
simulated distributions and stored. 

{marker Options2}{...}
{title:Detailed description of options}

{marker mandatory}{...}
{dlgtab: Mandatory}

{phang} {* GIC *}
 {opt gic(l|c|s)} Functional form of growth incidence curve (GIC) to be simulated. Linear {it:(l)}, convex {it:(c)} or step function {it:(s)}. See Lakner, Negre, and Prydz (2014) for details. 

{p 8 10}Linear {it:(l)}: The final welfare variable will be a combination of a transfer equal to a share of initial income minus a tax proportional to both the initial welfare and rank. That is, poorer individuals will be taxed lower and the tax 
increases proportionally with the rank.{p_end}

{p 8 10}Convex {it:(c)}: The final welfare variable is obtained as a combination of an overall growth rate, and a tax and transfer system with a single proportional tax and an equal absolute transfer.{p_end}

{phang} {* GROWTH *}
{opt growth(numlist)} Growth in the mean of the entire distribution. In Lakner, Negre and Prydz (2014) a country's annualized growth rate for either the last 10 or 20 years was used. Values should be specified in numeric rather than in percentage format. For instance, a growth rate of 5% should be given as 0.05. The range of values allowed is between -0.20(-20%) and 0.20 (20%). Could be a vector of growth rates of the same lenght as the number of repetitions. {p_end}

{phang} {* premium *}
{opt premium(numlist)} Growth premium, the percentage point (pp) difference in the growth rate of the mean of the poorest {it:X%} and of the overall mean and can be negative. This value was referred to as shared prosperity premium {it:(m)} in Lakner, Negre, and Prydz (2014). The range of values allowed is between -0.20 (-20 pp) and 0.20 (20 pp).{p_end}

{phang} {* Gini *}
{opt gini(numlist)} Alternativetly to using the shared prosperity premium, the overall change of gini can be set using the option {opt gini}. Notice that {opt gini} and {opt premium} can not be set at the same time. {p_end}

{phang} {* REPETITIONS *}
{opt repetitions(numlist)} Number of periods (e.g. {it:years}) to repeat the simulation. The maximum number of repetitions allowed is 50. 

{phang} {* PASSTHROUGH *}
{opt pass:through(numlist)} Passthrough rate i.e. the share of growth observed in national accounts that gets reflected in household level data. The acceptable range is >0 and <=2.

{marker optional}{...}
{dlgtab:Optional}

{phang} {* BOTTOM *}
{opt bottom(numlist)} Bottom {it:X%} group to which the growth premium {it:(premium)} should be applied. Default is bottom 40%, reflecting the World Bank's indicator of shared prosperity (annualized growth rate of the bottom 40%). 

{phang} {* OBS *}
{opt obs(numlist)} The number of observations that should be generated when using {it:ungroup} or the number of {it:fractiles} to be generated if collapsing the distribution before running simulations. If nothing is specified the simulation will 
be done on the data in memory without any modification.

{phang} {* VARMEAN *}
{opt varmean(numlist)} Specify variable containing mean of welfare distribution ({it:varname}) for data types {it:share} or {it:sharecum}. 

{phang} {* POVERTY *}
{opt poverty(string)} If this option is specified, the poverty headcount ratio is estimated for each period of the simulated data. {it:String} refers to the name of the dataset where the poverty estimates are stored. Baseline and final poverty 
estimates are printed in the result screen and stored in r().

{phang} {* LINES *}
{opt lines(numlist)} Set the poverty lines to be used in the poverty estimation. Multiple lies are allowed. Recall that the line should be express on the same basis i.e. monthly, nominal, real, per capita, etc, as the welfare variable. 

{phang} {* adjustp *}
{opt adjustp(numlist)} Specify number of attempts to adjust {it:premium} so that final annualized premium achieved after re-ranking of the distribution equals the {it:premium} set for the simulation. Default is no adjustment (0). E.g. if (10) is specified the re-estimation will be done at the most 10 times. 

{marker export}{...} 
{dlgtab:Export}

{phang} {* NAME *}
{opt name(string)} File name for simulated distributional data. 

{phang} {* FOLDER *}
{opt folder(string)} Directory for storing simulated distributional and poverty data.

{phang} {* REPLACE *}
{opt replace} Replace existing output with same file name in current directory or within the folder specified in the option above.{p_end}


{marker Examples}{...}
{title:Examples}
{pstd}

{dlgtab: Welfare (micro) data}

{p 8 12} use https://www.espenprydz.com/povsim/data_micro.dta {p_end}
{p 8 12} povsim pcexp [aw=weight], gic(l) growth(0.034) premium(0.02) repetitions(15) bottom(30) obs(1000) name(datafile) poverty(povertyfile) line(1.90) replace {p_end}

{pstd}This example uses a micro dataset with per capita expenditure stored in pcexp. The distribution is simulated over 15 periods, using a linear GIC with mean growth of 3.4% and a growth premium of 2% for the poorest 30% of the population. 
Poverty is estimated for the 1.90 line and stored in the file povertyfile.dta. The simulated distributions are stored in datafile.dta. 

{p 8 12} povsim pcexp [aw=weight], gic(l) growth(0.034) gini(0.02) repetitions(15) obs(1000) name(datafile) poverty(povertyfile) line(1.90) replace {p_end}

{pstd} Here we replicate the previous example but insted of using a shared properity premium, a change in gini is employed.

{dlgtab: Share data}

{p 8 12} use http://eprydz.com/povsim/data_deciles.dta,  clear{p_end}
{p 8 12} povsim share, type(share) gic(c) growth(0.03) premium(-0.01) varmean(mean) repetitions(5) ungroup name(file) obs(10000) replace {p_end}

{pstd} The above example uses a dataset of decile shares, which is ungrouped to 10,000 observations with the mean stored in varmean and simulated over 10 periods using a convex GIC with mean growth of 3% and a growth premium of negative 1% for 
the bottom 40%. No poverty estimates are conducted. 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:povsim} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(bottom)}}bottom() from command{p_end}
{synopt:{cmd:r(growth) }}growth() from command{p_end}
{synopt:{cmd:r(premium)}}premium() from command{p_end}
{synopt:{cmd:r(repetitions)}}repetitions() from command{p_end}
{synopt:{cmd:r(gbottomfi)}}final growth of mean in poorest X%{p_end}
{synopt:{cmd:r(gtopfi)}}final growth of mean in top 100-X%{p_end}
{synopt:{cmd:r(premium_actual)}}actual premium achieved after re-ranking of distribution{p_end}
{synopt:{cmd:r(basepov_1)}}poverty headcount ratio in base year - poverty line 1{p_end}
{synopt:{cmd:r(finalpov_1)}}poverty headcount ratio in final year - poverty line 1 {p_end}

{title:References}

{p 4 4 2}Lakner, Christoph, Mario Negre, and Espen Beer Prydz. 2014. 'The Role of inclusive Growth in Ending extreme Poverty'. {p_end}

{p 4 4 2}Lakner, Christoph, Mario Negre, and Espen Beer Prydz. 2014. 'Twinning the Goals: How Can Promoting Shared Prosperity Help to Reduce Global Poverty?' Policy Research Working Paper Series 7106. The World Bank. 

{p 4 4 2}Shorrocks, Anthony, and Guanghua Wan. 2008. 'Ungrouping income distributions.' in Arguments for a Better World: Essays in Honor of Amartya Sen: pp. 414-435.

{p 4 4 2}See the{browse "https://sites.google.com/site/decrgchristophlakner/twinning-poverty-simulations": Twinning - Poverty Simulations } page for more information{p_end}

	
{title:Authors}

{p 4 4 4}Santiago Garriga (Paris School of Economics); Christoph Lakner, The World Bank; Mario Negre, The World Bank; Espen Beer Prydz, The World Bank. For issues, questions email {browse "garrigasantiago@gmail.com":garrigasantiago@gmail.com} or 
{browse "eprydz@worldbank.org":eprydz@worldbank.org}. {p_end}

{title:Suggested citation}

{p 4 4 4} Garriga, Santiago, Christoph Lakner, Mario Negre, and Espen Beer Prydz. 2016. 'povsim: A Stata command for simulating changes in welfare distributions and poverty'. {p_end}


{title:Also see}

{psee}
 {helpb gicurve} (if installed), {helpb ungroup} (if installed), {helpb apoverty} (if installed)
{p_end}

