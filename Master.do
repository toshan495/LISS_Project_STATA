*Master.do

ssc install tabout,replace
ssc install catplot,replace

**SETTING UP PROJECT DIRECTORY
cd "C:\Program Files\Stata\Project"

*RUN DO FILE FOR CLEANING DATA
do Clean.do

*RUN DO FILE FOR MERGING DATA
do Merge.do

*RUN DO FILE FOR REGRESSION ANALYSIS
do Analysis.do

**************END*********************