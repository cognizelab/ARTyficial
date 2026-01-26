%% codes for finding significant clusters and reporting brain regions 

wb_command -cifti-find-clusters PC1_10k_pos_pvalue.dscalar.nii 0.0094 40 0.0094 80 COLUMN PC1_10k_pos_k10clusters.dscalar.nii -less-than -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii
wb_command -cifti-find-clusters PC1_10k_neg_pvalue.dscalar.nii 0.0094 40 0.0094 80 COLUMN PC1_10k_neg_k10clusters.dscalar.nii -less-than -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii

wb_command -cifti-find-clusters PC2_10k_pos_pvalue.dscalar.nii 0.0103 40 0.0103 80 COLUMN PC2_10k_pos_k10clusters.dscalar.nii -less-than -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii
wb_command -cifti-find-clusters PC2_10k_neg_pvalue.dscalar.nii 0.0103 40 0.0103 80 COLUMN PC2_10k_neg_k10clusters.dscalar.nii -less-than -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii

wb_command -cifti-find-clusters RSA_AEQ_dat_ztstat_uncp_c1.dscalar.nii 1.645 40 1.645 80 COLUMN RSA_AEQ_dat_ztstat_uncp_c1_clus.dscalar.nii -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii

wb_command -cifti-math '((x+y)>0) && (z>0)' G1_Intersection_signature.dscalar.nii -var x PC1_10k_pos_k10clusters.dscalar.nii -var y PC1_10k_neg_k10clusters.dscalar.nii -var z AAT_pc1_g4_bs10k_Haufe_FDRp_map.dscalar.nii
wb_command -cifti-find-clusters G1_Intersection_signature.dscalar.nii 0 40 0 80 COLUMN G1_Intersection_signature_k10clusters.dscalar.nii -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii


wb_command -cifti-math '((x+y)>0) && (z>0)' G2_Intersection_signature.dscalar.nii -var x PC2_10k_pos_k10clusters.dscalar.nii -var y PC2_10k_neg_k10clusters.dscalar.nii -var z AAT_pc2_g4_bs10k_Haufe_FDRp_map.dscalar.nii
wb_command -cifti-find-clusters G2_Intersection_signature.dscalar.nii 0 40 0 80 COLUMN G2_Intersection_signature_k10clusters.dscalar.nii -left-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii -right-surface /Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii


%% locate significant regions
clear;clc;
surf_L = gifti('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/HCP_Atlas_fsLR32k/S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii');
surf_R = gifti('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/HCP_Atlas_fsLR32k/S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii');
coord = [surf_L.vertices;surf_R.vertices];
Atlas_MW=cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/HCP_Atlas_fsLR32k/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii');
cortex_coord = coord(~Atlas_MW.cdata,:);


% load statistical maps and clusters
PC1_map = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/AATr_predictPC1_FS4_10k_weights_Zvalue.dscalar.nii');
PC2_map = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/AATr_predictPC2_FS4_10k_weights_Zvalue.dscalar.nii');
PC1_pos_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/PC1_10k_pos_k10clusters.dscalar.nii');
PC1_neg_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/PC1_10k_neg_k10clusters.dscalar.nii');
PC2_pos_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/PC2_10k_pos_k10clusters.dscalar.nii');
PC2_neg_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/PC2_10k_neg_k10clusters.dscalar.nii');
RSA_map = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/RSA_2D_Spearman_1000boots_tvalue.dscalar.nii');
RSA_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/RSA_2D_Spearman_1000boots_clusters.dscalar.nii');
RSAEQ_map = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/RSA_AEQ_dat_ztstat_c1.dscalar.nii');
RSAEQ_clus = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/Results/RSA_AEQ_dat_ztstat_uncp_c1_k10clusters.dscalar.nii');


PC1_map_cortical = PC1_map.cdata(1:59412,1);
PC2_map_cortical = PC2_map.cdata(1:59412,1);
PC1_map_sub = PC1_map.cdata(59413:end,1);
PC2_map_sub = PC2_map.cdata(59413:end,1);
RSA_map_cortical =RSA_map.cdata(1:59412,1);
RSAEQ_map_cortical =RSAEQ_map.cdata(1:59412,1);

% load MMP atlas
MMP = cifti_read('/Users/liangxinyu/Documents/Atlases/HCP_S1200_Atlas/Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii');
MMP_labels = squeeze(struct2cell(MMP.diminfo{1,2}.maps.table));
MMP_labelcell =MMP_labels(1:2,2:end)';
MMP_labelnames = cellfun(@(x) x(1:end-4), MMP_labelcell(:,1), 'UniformOutput', false);

% % load Melbourne subcortcial atlas
% SubsTian = cifti_read('/Users/liangxinyu/Documents/Atlases/Tian2020MSA/3T/Cortex-Subcortex/Gordon333.32k_fs_LR_Tian_Subcortex_S4.dlabel.nii');
% SubcorticalTian = squeeze(struct2cell(SubsTian.diminfo{1,2}.maps.table))';
% SubcorticalTian_label = SubcorticalTian(2:55,1:2);
% SubcorticalTian_indices = SubsTian.cdata;
% MSA = SubcorticalTian_indices(59413:end);

% load Freesurfer subcortcial atlas
SubsFS = cifti_read('/Users/liangxinyu/Documents/Seafiles/Seafile/ARTyficial/ARTyficial_signatures/HCP_Atlas_fsLR32k/Gordon333_FreesurferSubcortical.32k_fs_LR.dlabel.nii');
SubcorticalFS = squeeze(struct2cell(SubsFS.diminfo{1,2}.maps.table))';
SubcorticalFS_label = SubcorticalFS(335:end,1:2);
SFS = SubsFS.cdata(59413:end)-333;
Subregion_voxels = [];
Subregion_names = cell(19,2);
for i=1:19
    temp_struct = SubsFS.diminfo{1,1}.models{1,i+2};
    Subregion_names{i,1} = temp_struct.struct;
    Subregion_names{i,2} = temp_struct.start;
    Subregion_names{i,3} = temp_struct.count;
    Subregion_voxels = [Subregion_voxels,temp_struct.voxlist];
end
sform_code=SubsFS.diminfo{1,1}.vol.sform;
Subregion_coord = sform_code(1:3,1:3)*Subregion_voxels+sform_code(1:3,4);

%% cortical part

PC1_pos_clus_cortical = PC1_pos_clus.cdata(1:59412,1);
PC1_pos_clus_info =cell(max(PC1_pos_clus_cortical),9);
for clusid = 1:max(PC1_pos_clus_cortical)
    clus_ind = (PC1_pos_clus_cortical==clusid);
    clus_region = PC1_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = []; 

    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    PC1_pos_clus_info{clusid,1} =clusid;
    PC1_pos_clus_info{clusid,2} =clus_size;
    PC1_pos_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC1_pos_clus_info{clusid,4} =round(Peak_MNI(1));
    PC1_pos_clus_info{clusid,5} =round(Peak_MNI(2));
    PC1_pos_clus_info{clusid,6} =round(Peak_MNI(3));
    PC1_pos_clus_info{clusid,7} =Peak_MMP;
    PC1_pos_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    PC1_pos_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end

PC1_neg_clus_cortical = PC1_neg_clus.cdata(1:59412,1);
PC1_neg_clus_info =cell(max(PC1_neg_clus_cortical),9);
for clusid = 1:max(PC1_neg_clus_cortical)
    clus_ind = (PC1_neg_clus_cortical==clusid);
    clus_region = PC1_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = min(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = []; 

    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    PC1_neg_clus_info{clusid,1} =clusid;
    PC1_neg_clus_info{clusid,2} =clus_size;
    PC1_neg_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC1_neg_clus_info{clusid,4} =round(Peak_MNI(1));
    PC1_neg_clus_info{clusid,5} =round(Peak_MNI(2));
    PC1_neg_clus_info{clusid,6} =round(Peak_MNI(3));
    PC1_neg_clus_info{clusid,7} =Peak_MMP;
    PC1_neg_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    PC1_neg_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end


PC2_pos_clus_cortical = PC2_pos_clus.cdata(1:59412,1);
PC2_pos_clus_info =cell(max(PC2_pos_clus_cortical),9);
for clusid = 1:max(PC2_pos_clus_cortical)
    clus_ind = (PC2_pos_clus_cortical==clusid);
    clus_region = PC2_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = []; 

    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    PC2_pos_clus_info{clusid,1} =clusid;
    PC2_pos_clus_info{clusid,2} =clus_size;
    PC2_pos_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC2_pos_clus_info{clusid,4} =round(Peak_MNI(1));
    PC2_pos_clus_info{clusid,5} =round(Peak_MNI(2));
    PC2_pos_clus_info{clusid,6} =round(Peak_MNI(3));
    PC2_pos_clus_info{clusid,7} =Peak_MMP;
    PC2_pos_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    PC2_pos_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end

PC2_neg_clus_cortical = PC2_neg_clus.cdata(1:59412,1);
PC2_neg_clus_info =cell(max(PC2_neg_clus_cortical),9);
for clusid = 1:max(PC2_neg_clus_cortical)
    clus_ind = (PC2_neg_clus_cortical==clusid);
    clus_region = PC2_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = min(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = []; 
    
    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    PC2_neg_clus_info{clusid,1} =clusid;
    PC2_neg_clus_info{clusid,2} =clus_size;
    PC2_neg_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC2_neg_clus_info{clusid,4} =round(Peak_MNI(1));
    PC2_neg_clus_info{clusid,5} =round(Peak_MNI(2));
    PC2_neg_clus_info{clusid,6} =round(Peak_MNI(3));
    PC2_neg_clus_info{clusid,7} =Peak_MMP;
    PC2_neg_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    PC2_neg_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end

RSA_clus_cortical = RSA_clus.cdata(1:59412,1);
RSA_clus_info =cell(max(RSA_clus_cortical),9);
for clusid = 1:max(RSA_clus_cortical)
    clus_ind = (RSA_clus_cortical==clusid);
    clus_region = RSA_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<5,:) = []; 
    
    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    RSA_clus_info{clusid,1} =clusid;
    RSA_clus_info{clusid,2} =clus_size;
    RSA_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    RSA_clus_info{clusid,4} =round(Peak_MNI(1));
    RSA_clus_info{clusid,5} =round(Peak_MNI(2));
    RSA_clus_info{clusid,6} =round(Peak_MNI(3));
    RSA_clus_info{clusid,7} =Peak_MMP;
    RSA_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    RSA_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end


RSAEQ_clus_cortical = RSAEQ_clus.cdata(1:59412,1);
RSAEQ_clus_info =cell(max(RSAEQ_clus_cortical),9);
for clusid = 1:max(RSAEQ_clus_cortical)
    clus_ind = (RSAEQ_clus_cortical==clusid);
    clus_region = RSAEQ_map_cortical.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);
    Peak_MMP = MMP_labelnames{MMP.cdata(Peak_ind),1};
    Peak_MNI = cortex_coord(Peak_ind,:);
    Clus_MMP = MMP.cdata(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_MMP);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<5,:) = []; 
    
    Clus_MMP_names=MMP_labelnames(T(:,1))';
    Clus_MMP_percentage=round(T(:,2)');
    RSAEQ_clus_info{clusid,1} =clusid;
    RSAEQ_clus_info{clusid,2} =clus_size;
    RSAEQ_clus_info{clusid,3} =num2str(Peak_value,'%0.2f');
    RSAEQ_clus_info{clusid,4} =round(Peak_MNI(1));
    RSAEQ_clus_info{clusid,5} =round(Peak_MNI(2));
    RSAEQ_clus_info{clusid,6} =round(Peak_MNI(3));
    RSAEQ_clus_info{clusid,7} =Peak_MMP;
    RSAEQ_clus_info{clusid,8} =strjoin(Clus_MMP_names, ', ');
    RSAEQ_clus_info{clusid,9} =strjoin(split( num2str(Clus_MMP_percentage)),', ');
end



%% Subcortical part

PC1_pos_clus_sub = PC1_pos_clus.cdata(59413:end,1);
PC1_pos_clus_sub_info =cell(max(PC1_pos_clus_sub)-max(PC1_pos_clus_cortical),9);
SubIDs = unique(PC1_pos_clus_sub);
for clusid = 1:size(PC1_pos_clus_sub_info,1)
    clus_ind = (PC1_pos_clus_sub==SubIDs(clusid+1));
    clus_region = PC1_map_sub.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);

    Peak_SFS = SubcorticalFS_label{SFS(Peak_ind),1};
    Peak_MNI= Subregion_coord(:,Peak_ind)';
    Clus_SFS = SFS(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_SFS);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = [];

    Clus_SFS_names=SubcorticalFS_label(T(:,1))';
    Clus_SFS_percentage=round(T(:,2)');
    PC1_pos_clus_sub_info{clusid,1} =clusid;
    PC1_pos_clus_sub_info{clusid,2} =clus_size;
    PC1_pos_clus_sub_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC1_pos_clus_sub_info{clusid,4} =round(Peak_MNI(1));
    PC1_pos_clus_sub_info{clusid,5} =round(Peak_MNI(2));
    PC1_pos_clus_sub_info{clusid,6} =round(Peak_MNI(3));
    PC1_pos_clus_sub_info{clusid,7} =Peak_SFS;
    PC1_pos_clus_sub_info{clusid,8} =strjoin(Clus_SFS_names, ', ');
    PC1_pos_clus_sub_info{clusid,9} =strjoin(split( num2str(Clus_SFS_percentage)),', ');

end

PC1_neg_clus_sub = PC1_neg_clus.cdata(59413:end,1);
PC1_neg_clus_sub_info =cell(max(PC1_neg_clus_sub)-max(PC1_neg_clus_cortical),9);
SubIDs = unique(PC1_neg_clus_sub);
for clusid = 1:size(PC1_neg_clus_sub_info,1)
    clus_ind = (PC1_neg_clus_sub==SubIDs(clusid+1));
    clus_region = PC1_map_sub.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = min(clus_region);

    Peak_SFS = SubcorticalFS_label{SFS(Peak_ind),1};
    Peak_MNI= Subregion_coord(:,Peak_ind)';
    Clus_SFS = SFS(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_SFS);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = [];

    Clus_SFS_names=SubcorticalFS_label(T(:,1))';
    Clus_SFS_percentage=round(T(:,2)');
    PC1_neg_clus_sub_info{clusid,1} =clusid;
    PC1_neg_clus_sub_info{clusid,2} =clus_size;
    PC1_neg_clus_sub_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC1_neg_clus_sub_info{clusid,4} =round(Peak_MNI(1));
    PC1_neg_clus_sub_info{clusid,5} =round(Peak_MNI(2));
    PC1_neg_clus_sub_info{clusid,6} =round(Peak_MNI(3));
    PC1_neg_clus_sub_info{clusid,7} =Peak_SFS;
    PC1_neg_clus_sub_info{clusid,8} =strjoin(Clus_SFS_names, ', ');
    PC1_neg_clus_sub_info{clusid,9} =strjoin(split( num2str(Clus_SFS_percentage)),', ');

end

PC2_pos_clus_sub = PC2_pos_clus.cdata(59413:end,1);
PC2_pos_clus_sub_info =cell(max(PC2_pos_clus_sub)-max(PC2_pos_clus_cortical),9);
SubIDs = unique(PC2_pos_clus_sub);
for clusid = 1:size(PC2_pos_clus_sub_info,1)
    clus_ind = (PC2_pos_clus_sub==SubIDs(clusid+1));
    clus_region = PC2_map_sub.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = max(clus_region);

    Peak_SFS = SubcorticalFS_label{SFS(Peak_ind),1};
    Peak_MNI= Subregion_coord(:,Peak_ind)';
    Clus_SFS = SFS(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_SFS);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = [];

    Clus_SFS_names=SubcorticalFS_label(T(:,1))';
    Clus_SFS_percentage=round(T(:,2)');
    PC2_pos_clus_sub_info{clusid,1} =clusid;
    PC2_pos_clus_sub_info{clusid,2} =clus_size;
    PC2_pos_clus_sub_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC2_pos_clus_sub_info{clusid,4} =round(Peak_MNI(1));
    PC2_pos_clus_sub_info{clusid,5} =round(Peak_MNI(2));
    PC2_pos_clus_sub_info{clusid,6} =round(Peak_MNI(3));
    PC2_pos_clus_sub_info{clusid,7} =Peak_SFS;
    PC2_pos_clus_sub_info{clusid,8} =strjoin(Clus_SFS_names, ', ');
    PC2_pos_clus_sub_info{clusid,9} =strjoin(split( num2str(Clus_SFS_percentage)),', ');

end

PC2_neg_clus_sub = PC2_neg_clus.cdata(59413:end,1);
PC2_neg_clus_sub_info =cell(max(PC2_neg_clus_sub)-max(PC2_neg_clus_cortical),9);
SubIDs = unique(PC2_neg_clus_sub);
for clusid = 1:size(PC2_neg_clus_sub_info,1)
    clus_ind = (PC2_neg_clus_sub==SubIDs(clusid+1));
    clus_region = PC2_map_sub.*clus_ind;
    clus_size = sum(clus_ind);
    [Peak_value,Peak_ind] = min(clus_region);

    Peak_SFS = SubcorticalFS_label{SFS(Peak_ind),1};
    Peak_MNI= Subregion_coord(:,Peak_ind)';
    Clus_SFS = SFS(clus_ind);
    [GC,GR,GP] = groupcounts(Clus_SFS);
    T = sortrows([GR,GP], 2, 'descend');
    T(T(:,2)<10,:) = [];

    Clus_SFS_names=SubcorticalFS_label(T(:,1))';
    Clus_SFS_percentage=round(T(:,2)');
    PC2_neg_clus_sub_info{clusid,1} =clusid;
    PC2_neg_clus_sub_info{clusid,2} =clus_size;
    PC2_neg_clus_sub_info{clusid,3} =num2str(Peak_value,'%0.2f');
    PC2_neg_clus_sub_info{clusid,4} =round(Peak_MNI(1));
    PC2_neg_clus_sub_info{clusid,5} =round(Peak_MNI(2));
    PC2_neg_clus_sub_info{clusid,6} =round(Peak_MNI(3));
    PC2_neg_clus_sub_info{clusid,7} =Peak_SFS;
    PC2_neg_clus_sub_info{clusid,8} =strjoin(Clus_SFS_names, ', ');
    PC2_neg_clus_sub_info{clusid,9} =strjoin(split( num2str(Clus_SFS_percentage)),', ');

end




%% save results
Header = {'Cluster ID','Cluster size','Peak value','Peak x','Peak y','Peak z',...
    'Peak region label','Region labels','Region percentage'};
combinedData_PC1_pos = [Header;PC1_pos_clus_info;PC1_pos_clus_sub_info];
combinedData_PC1_neg = [Header;PC1_neg_clus_info;PC1_neg_clus_sub_info];
combinedData_PC2_pos = [Header;PC2_pos_clus_info;PC2_pos_clus_sub_info];
combinedData_PC2_neg = [Header;PC2_neg_clus_info;PC2_neg_clus_sub_info];
combinedData_RSA = [Header;RSA_clus_info];
combinedData_RSAEQ = [Header;RSAEQ_clus_info];

save('Significant_clusters_report.mat','combinedData_PC1_pos','combinedData_PC1_neg','combinedData_PC2_pos','combinedData_PC2_neg','combinedData_RSA');

combinedData_PC1 = [Header;PC1_pos_clus_info;PC1_pos_clus_sub_info;PC1_neg_clus_info;PC1_neg_clus_sub_info];
combinedData_PC2 = [Header;PC2_pos_clus_info;PC2_pos_clus_sub_info;PC2_neg_clus_info;PC2_neg_clus_sub_info];

writecell(combinedData_PC1, 'SignatureClusters_PC1_all.xlsx');
writecell(combinedData_PC2, 'SignatureClusters_PC2_all.xlsx');
writecell(combinedData_RSAEQ, 'SignatureClusters_RSAxAEQ_cort.xlsx');


