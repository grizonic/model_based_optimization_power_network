function [transS, t] = getProfile(multiFactor)
% Loads profile of Jan 29 2006 Fig
e_cp=d_ecp_winter;


jan29=27*60/15*24+1;
day=24*60/15;

daydata=e_cp(jan29:jan29+day);
nordaydata=daydata/max(daydata);

t15=0:15:day*15;


t1=0:(24*60-1);
norday1=interp1(t15,nordaydata,t1);

transS=multiFactor*norday1;
t=t1;

