function [lineData]= getXfmData(thhsInit,thoilInit)
% gives transformer data for IEC std transformer
% used in chapter 3 of thesis

lineData.transInd=1;
lineData.transRating=1;
% lineData.sMax=100;
% lineData.sMaxInd=1;
lineData.numSMax=1;
lineData.thhs=thhsInit;
lineData.thoil=thoilInit;
