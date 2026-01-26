% load RSA searchlight results and save them
RSAfiles = g_ls('../R*_RSA.mat');

RSAinds = zeros(34,64984);
for i = 1:34
    cortdata = load(RSAfiles{i});

    temp_cort = atanh(cortdata.ds_rsm_behav.samples(1,:));
    temp_cort_rand_avg = mean(atanh(cortdata.rsa_tmp_rands));
    temp_cort(isnan(temp_cort)) =0;
    temp_cort_rand_avg(isnan(temp_cort_rand_avg)) =0;

    RSAinds(i,:) = (temp_cort-temp_cort_rand_avg);
    disp(['Subnum-',num2str(i),' Done!']);
end

filename ='RSAsearchlight_Euclidean.mat';
save(filename,'RSAinds');
