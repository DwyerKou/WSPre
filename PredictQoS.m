function [sensitive_flag, evaluation_WSPre] = PredictQoS(matrix_sparse, u, s, top_k, w, theta)
%%Ԥ��QoSֵ

%load('matrix_sparse.mat')

[~, service_num] = size(matrix_sparse);
sensitive_flag = 0;
evaluation_WSPre = nan;
if ~isnan(matrix_sparse(u, s))
    evaluation_WSPre = matrix_sparse(u, s);
end

%�ж�s�ǲ������з���
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

%ȥ�����з����ʣ��-1��Ϊnan�������¼���service_num
matrix_sparse(matrix_sparse == -1) = nan;
[user_num, service_num] = size(matrix_sparse);

%�ָ�ʵ���ø�����������
nagetive_filter = isnan(matrix_sparse); %����������Ҫ���Ĳ���

%�����������ƶ�
user_mean_sparse = mean(matrix_sparse, 2, 'omitnan')';  %��ȡ�û�ƽ��ֵ,ע����ܴ���nan
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

%�����֮ǰԤ��UMEAN��IMEAN��UPCC�Լ�IPCC��UC�Լ�IC
count_training = user_num;
%evaluation_UPCC = UPCC_Zero(matrix_sparse, count_training, u, s, top_k, user_similarity_sparse);
%evaluation_IPCC = IPCC_Zero(matrix_sparse, count_training, u, s, top_k, service_similarity_sparse);


%��ʼ��� �������������� ��ֻ��ѵ����
matrix_sparse_filled = MissingValuePrediction(matrix_sparse, nagetive_filter, top_k, w, user_similarity_sparse, service_similarity_sparse);
user_mean = mean(matrix_sparse_filled, 2, 'omitnan')';  %��ȡ�û�ƽ��ֵ,ע����ܴ���nan
service_mean = mean(matrix_sparse_filled, 'omitnan');
%��ǰ����������ƶȣ�Ȼ�󱣴���������������Լ����㷨��Ҫ
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

%Ԥ��WSRec��Dwyer
flag_second = 2;
evaluation_WSPre_UPCC = UPCC_nan(matrix_sparse_filled, count_training, u, s, top_k, user_similarity);
evaluation_WSPre_IPCC = IPCC_nan(matrix_sparse_filled, count_training, u, s, top_k, service_similarity);
evaluation_WSPre = WSRec(evaluation_WSPre_UPCC, evaluation_WSPre_IPCC,...
    w, flag_second, user_mean(u), service_mean(s));