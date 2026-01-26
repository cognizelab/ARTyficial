%% get the prediction models
G1_data = load('Data/ART_G1_4lvl_predictiondata.mat');
G2_data = load('Data/ART_G2_4lvl_predictiondata.mat');

svrobj_G1 = svr({'C=1', 'optimizer="andre"', kernel('linear')});
svrobj_G2 = svr({'C=1', 'optimizer="andre"', kernel('linear')});

dataobj_G1 = data('spider data', double(G1_data.AATpredition.dat)', G1_data.AATpredition.Y);
dataobj_G2 = data('spider data', double(G2_data.AATpredition.dat)', G2_data.AATpredition.Y);
[~, svrobj_G1] = train(svrobj_G1, dataobj_G1, loss);
[~, svrobj_G2] = train(svrobj_G2, dataobj_G2, loss);

weights_G1 = get_w(svrobj_G1)';
weights_G2 = get_w(svrobj_G2)';

%% load contrast maps from HCP dataset

load('Data/HCP_generalization_contrast.mat')

% gambling task
similarity_generalvalence_map_G1 = canlab_pattern_similarity(general_valence_contrast', weights_G1, 'cosine_similarity');
similarity_generalvalence_map_G2 = canlab_pattern_similarity(general_valence_contrast', weights_G2, 'cosine_similarity');

C1_hex = {'#9dc4db','#e9a888'};
C1_RGB = cellfun(@(x) sscanf(x(2:end),'%2x%2x%2x',[1 3])/255, C1_hex, 'UniformOutput', false);
labels = {'Semantic','Value'};
barplot_columns([similarity_generalvalence_map_G1,similarity_generalvalence_map_G2],...
    'names',labels,'color',C1_RGB,'nostars','MarkerSize',5);
ylim([-0.12,0.12])
set(gcf,'position',[10,10,550,750])
ylabel 'Signature Response (Cosine Similarity)'

% working memory task
similarity_placevsface_map_G1 = canlab_pattern_similarity(placevsface_contrast', weights_G1, 'cosine_similarity');
similarity_placevsface_map_G2 = canlab_pattern_similarity(placevsface_contrast', weights_G2, 'cosine_similarity');

C2_hex = {'#b8262b','#316eac'};
C2_RGB = cellfun(@(x) sscanf(x(2:end),'%2x%2x%2x',[1 3])/255, C2_hex, 'UniformOutput', false);
labels = {'Semantic','Value'};
barplot_columns([similarity_placevsface_map_G1,similarity_placevsface_map_G2],'names',labels,'color',C2_RGB,'nostars');
ylim([-0.1,0.2])
set(gcf,'position',[10,10,550,750])
ylabel 'Signature Response (Cosine Similarity)'


