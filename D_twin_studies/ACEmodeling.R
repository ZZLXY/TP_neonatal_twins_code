
##read data
library(umx)
library(readxl)
library("R.matlab")

# define the path of the data matrix
path<-("XXX")

# load the data matrix
# Organize your phenotypic data (e.g. dTP-Langauge_FC) into two columns by twin, 
# one of which is for twin 1, and you need to name it dTP-Language_FC1; 
# The other column is for twins 2, which you need to name it dTP-Language_FC2.
data=read_excel(paste(path, "FCmatrix.xlsx", sep = "/"))

destfolder<-(paste(path, "Modeling_Results_Net", sep = "/"))
dir.create(destfolder)
# load the the name of the traits
TraitName = read_excel(paste(path, "TraitName.xlsx", sep = "/"))
TraitNum = length(data.frame(TraitName)[,1])

##save results: AIC, BIC, fit loglike, a, c, e
result_ace=matrix(0,TraitNum,9)
result_ae=matrix(0,TraitNum,9)
result_ce=matrix(0,TraitNum,9)
result_e=matrix(0,TraitNum,9)
result_compare_ace=matrix(0,TraitNum,10)##ace-ae,ace-ce,ace-e,ae-e,ce-e change direction and p

mz_Data=subset(data,Zygosity==1)
dz_Data=subset(data,Zygosity==2)


##run the data
for (i in 1:TraitNum){

  ## run model
  CurrTrait = as.vector(unlist(TraitName[i,1]))
  ##for ace and submodel
  mace = umxACE(selDVs = CurrTrait, selCovs = c("Age", "Gender"), sep = "", dzData = dz_Data, mzData = mz_Data)
  mae=umxModify(mace, update = "c_r1c1", name = "AE")
  mce=umxModify(mace, update = "a_r1c1", name = "CE")
  me=umxModify(mae, update = "a_r1c1", name = "E")
  
  ## save ace and submodel result
  ##ace
  mace_stats=summary(mace)
  result_ace[i,1]=mace_stats[["AIC.Mx"]]
  result_ace[i,2]=mace_stats[["BIC.Mx"]]
  result_ace[i,3]=mace@fitfunction$result[1,1]  #-2LL
  result_ace[i,4]=mace@output$algebras$top.a_std[1,1] #a estimate
  result_ace[i,5]=mace@output$algebras$top.c_std[1,1] #c estimate
  result_ace[i,6]=mace@output$algebras$top.e_std[1,1] #e estimate
  result_ace[i,7]=mace@output$standardErrors[4,1] # a SE
  result_ace[i,8]=mace@output$standardErrors[5,1] # c SE
  result_ace[i,9]=mace@output$standardErrors[6,1] # e SE
  ##ae
  mae_stats=summary(mae)
  result_ae[i,1]=mae_stats[["AIC.Mx"]]
  result_ae[i,2]=mae_stats[["BIC.Mx"]]
  result_ae[i,3]=mae@fitfunction$result[1,1]
  result_ae[i,4]=mae@output$algebras$top.a_std[1,1]
  result_ae[i,5]=mae@output$algebras$top.c_std[1,1]
  result_ae[i,6]=mae@output$algebras$top.e_std[1,1]
  result_ae[i,7]=mae@output$standardErrors[4,1]
  result_ae[i,9]=mae@output$standardErrors[5,1]
  ##ce
  mce_stats=summary(mce)
  result_ce[i,1]=mce_stats[["AIC.Mx"]]
  result_ce[i,2]=mce_stats[["BIC.Mx"]]
  result_ce[i,3]=mce@fitfunction$result[1,1]
  result_ce[i,4]=mce@output$algebras$top.a_std[1,1]
  result_ce[i,5]=mce@output$algebras$top.c_std[1,1]
  result_ce[i,6]=mce@output$algebras$top.e_std[1,1]
  result_ce[i,8]=mce@output$standardErrors[4,1]
  result_ce[i,9]=mce@output$standardErrors[5,1]
  ##e
  me_stats=summary(me)
  result_e[i,1]=me_stats[["AIC.Mx"]]
  result_e[i,2]=me_stats[["BIC.Mx"]]
  result_e[i,3]=me@fitfunction$result[1,1]
  result_e[i,4]=me@output$algebras$top.a_std[1,1]
  result_e[i,5]=me@output$algebras$top.c_std[1,1]
  result_e[i,6]=me@output$algebras$top.e_std[1,1]
  result_e[i,9]=me@output$standardErrors[4,1]

  ## model comparison: with ace model
  ace_ae=umxCompare(mace,mae)
  ace_ce=umxCompare(mace,mce)
  ace_e=umxCompare(mace,me)
  ae_e=umxCompare(mae,me)
  ce_e=umxCompare(mce,me)
  result_compare_ace[i,1]=ace_ae[2,7]
  result_compare_ace[i,2]=ace_ae[2,5]
  result_compare_ace[i,3]=ace_ce[2,7]
  result_compare_ace[i,4]=ace_ce[2,5]
  result_compare_ace[i,5]=ace_e[2,7]
  result_compare_ace[i,6]=ace_e[2,5]
  result_compare_ace[i,7]=ae_e[2,7]
  result_compare_ace[i,8]=ae_e[2,5]
  result_compare_ace[i,9]=ce_e[2,7]
  result_compare_ace[i,10]=ce_e[2,5]
}
## change form
result_ace = data.frame(result_ace)
result_ae = data.frame(result_ae)
result_ce = data.frame(result_ce)
result_e=data.frame(result_e)
result_compare_ace = data.frame(result_compare_ace)

## write data
idx = "FC"
ace_file_name=paste("ace_",idx,".txt",sep='')
ace_dest<-file.path(destfolder,ace_file_name)
write.table(result_ace,ace_dest,row.names = FALSE,col.names = FALSE)
ae_file_name=paste("ae_",idx,".txt",sep='')
ae_dest<-file.path(destfolder,ae_file_name)
write.table(result_ae,ae_dest,row.names = FALSE,col.names = FALSE)
ce_file_name=paste("ce_",idx,".txt",sep='')
ce_dest<-file.path(destfolder,ce_file_name)
write.table(result_ce,ce_dest,row.names = FALSE,col.names = FALSE)
e_file_name=paste("e_",idx,".txt",sep='')
e_dest<-file.path(destfolder,e_file_name)
write.table(result_e,e_dest,row.names = FALSE,col.names = FALSE)
compare_ace_file_name=paste("compare_ace_",idx,".csv",sep='')
compare_ace_dest<-file.path(destfolder,compare_ace_file_name)
write.csv(result_compare_ace,compare_ace_dest,row.names = FALSE, col.names = FALSE)

