function [sensitive_flag, evaluation_WSPre] = PredictQoS(matrix_sparse, u, s, top_k, w, theta)
%%预测QoS值

%load('matrix_sparse.mat')

[~, service_num] = size(matrix_sparse);
sensitive_flag = 0;
evaluation_WSPre = nan;
if ~isnan(matrix_sparse(u, s))
    evaluation_WSPre = matrix_sparse(u, s);
end

%判断s是不是敏感服务
col_s = matrix_sparse(:, s);
num_nonan = numel(find(~isnan(col_s)));
num_sensitive = numel(find(col_s == -1));
if num_sensitive/num_nonan > theta
    sensitive_flag = 1;
    return
end

for m = service_num: -1 :1
    t = matrix_sparse(:, m);
    num_nonan = numel(find(~isnan(t)));
    num_sensitive = numel(find(t == -1));
    if num_sensitive/num_nonan > theta
        matrix_sparse(:, m) = [];
    end
end

%去掉敏感服务后将剩余-1置为nan，并重新计算service_num
matrix_sparse(matrix_sparse == -1) = nan;
[user_num, service_num] = size(matrix_sparse);

%分割实验用各个部分数据
nagetive_filter = isnan(matrix_sparse); %整个矩阵需要填充的部分

%计算所有相似度
user_mean_sparse = mean(matrix_sparse, 2, 'omitnan')';  %获取用户平均值,注意可能存在nan
service_mean_sparse = mean(matrix_sparse, 'omitnan');
user_similarity_sparse = zeros(user_num, user_num);
service_similarity_sparse = zeros(service_num, service_num);
for m = 1:user_num
    for n = 1:user_num
        user_similarity_sparse(m, n) = PCC_nan(m, n, matrix_sparse, user_mean_sparse);
    end
end
for m = 1:service_num
    for n = 1:service_num
        service_similarity_sparse(m, n) = PCC_nan(m, n, matrix_sparse', service_mean_sparse);
    end
end

%在填充之前预测UMEAN、IMEAN、UPCC以及IPCC、UC以及IC
count_training = user_num;
%evaluation_UPCC = UPCC_Zero(matrix_sparse, count_training, u, s, top_k, user_similarity_sparse);
%evaluation_IPCC = IPCC_Zero(matrix_sparse, count_training, u, s, top_k, service_similarity_sparse);


%开始填充 填充的是整个矩阵 不只是训练集
matrix_sparse_filled = MissingValuePrediction(matrix_sparse, nagetive_filter, top_k, w, user_similarity_sparse, service_similarity_sparse);
user_mean = mean(matrix_sparse_filled, 2, 'omitnan')';  %获取用户平均值,注意可能存在nan
service_mean = mean(matrix_sparse_filled, 'omitnan');
%提前算好所有相似度，然后保存起来，这个是我自己的算法需要
user_similarity = zeros(user_num, user_num);
service_similarity = zeros(service_num, service_num);
for m = 1:user_num
    for n = 1:user_num
        user_similarity(m, n) = PCC_nan(m, n, matrix_sparse_filled, user_mean);
    end
end
for m = 1:service_num
    for n = 1:service_num
        service_similarity(m, n) = PCC_nan(m, n, matrix_sparse_filled', service_mean);
    end
end

%预测WSRec与Dwyer
flag_second = 2;
evaluation_WSPre_UPCC = UPCC_nan(matrix_sparse_filled, count_training, u, s, top_k, user_similarity);
evaluation_WSPre_IPCC = IPCC_nan(matrix_sparse_filled, count_training, u, s, top_k, service_similarity);
evaluation_WSPre = WSRec(evaluation_WSPre_UPCC, evaluation_WSPre_IPCC,...
    w, flag_second, user_mean(u), service_mean(s));