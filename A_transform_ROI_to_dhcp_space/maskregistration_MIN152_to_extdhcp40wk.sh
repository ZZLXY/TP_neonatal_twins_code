#! /bin/bash

#The adult MNI152 template used could be download from: https://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009
#The template_t2.nii used could be download form: https://gin.g-node.org/BioMedIA/dhcp-volumetric-atlas-groupwise
#The extended dHCP volumetric atlas and transformation matrix used could be download from:https://git.fmrib.ox.ac.uk/seanf/dhcp-resources/-/blob/master/docs/dhcp-augmented-volumetric-atlas-extended.md#download-42-gb

#We used a two-step registration approach: first, transforming the adult ROI to the template_t2 space (dhcp release 2), and then to the extdhcp40wk space (release 3). 
#Careful inspection revealed that the ROI transformed to the newborn space was more accurate using this method.

#codes used to generate the registration matrix for transform the atlas in MNI152 09a space into template t2 space (dhcp release 2)
#antsRegistrationSyNQuick.sh -d 3 -f template_t2.nii -m mni_icbm152_t1_tal_nlin_asym_09a_brain.nii -o ICBM1522newborn


##used codes to normalize ICBM152 to newborn spaces
#antsApplyTransforms -d 3 -i mni_icbm152_t1_tal_nlin_asym_09a_brain.nii -o mni_icbm152_t1_tal_nlin_asym_09a_brain_2extdhcp40wk.nii -r week40_T2w.nii.gz -t dhcp40wk_to_extdhcp40wk_warp.nii.gz -t ICBM1522newborn1Warp.nii.gz -t ICBM1522newborn0GenericAffine.mat


# Read list of subjects.



images=(
'TP'
'Name_of_your_ROIs'

);

cd /to_your_path

pre="ICBM152"





for ((i=0;i<=23;i++))


do

tempimg=${images[i]};

###upsample brain mask to match with week40_T2w.nii.gz

flirt -in MASKS/${tempimg}_mask.nii -applyisoxfm 0.5 -ref MASKS/${tempimg}_mask.nii -out MASKS/upsample_${tempimg}_mask.nii -init $FSLDIR/etc/flirtsch/ident.mat

mri_binarize --i MASKS/upsample_${tempimg}_mask.nii.gz --min 0.1 --o MASKS/bi_upsample_${tempimg}_mask.nii.gz



# negate the mask

ImageMath 3 MASKS/${tempimg}_neg.img Neg MASKS/bi_upsample_${tempimg}_mask.nii.gz

## normalize the negative mask
## use antsRegistrationSyNQuick.sh -d 3 -f /template_t2.nii -m colin27_t1_tal_hires_brain.nii -o colin2newborn to generate the transformation matrix


antsApplyTransforms -d 3 -i MASKS/${tempimg}_neg.img -o MASKS/neg_deform_${pre}${tempimg}_mask.nii -r week40_T2w.nii.gz -t dhcp40wk_to_extdhcp40wk_warp.nii.gz -t ICBM1522newborn1Warp.nii.gz -t ICBM1522newborn0GenericAffine.mat

## negate back to the intended mask

ImageMath 3 MASKS/${pre}_deform_${tempimg}_mask.nii Neg MASKS/neg_deform_${pre}${tempimg}_mask.nii


##need to generate a mask cutting part of brain stem, so no border voxels were included

fslmaths MASKS/${pre}_deform_${tempimg}_mask.nii -mas week40_T2w_y2_z18.nii MASKS/correct_${pre}_deform_${tempimg}.nii.gz


## reslice to functional space

flirt -in MASKS/correct_${pre}_deform_${tempimg}.nii.gz -applyisoxfm 2.132353 -ref week40_T2w_downsamplefunc.nii.gz -out MASKS/func_correct_mask_${pre}_deform_${tempimg}.nii -init $FSLDIR/etc/flirtsch/ident.mat


## binarize the mask

mri_binarize --i MASKS/func_correct_mask_${pre}_deform_${tempimg}.nii.gz --min 0.5 --o MASKS/bi_func_correct_mask_${pre}_deform_${tempimg}.nii.gz


mri_convert MASKS/bi_func_correct_mask_${pre}_deform_${tempimg}.nii.gz MASKS/Final_bi_mask_${pre}_deform_${tempimg}.nii


unset tempimg


echo "\nfinishing for ${i}\n"





done






