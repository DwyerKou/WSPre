function qos_value = IPCC_Zero(matrix, count_training, u, s, top_k, service_similarity_sparse)
%%����matrix��Ԥ���û�u����s��QoSֵ,��дUPCC
%���ǵ�UPCC��IPCC�㷨��ȫ��ͬ����ͬ�����൱�ڰѾ��������ת��
%update_12.24 ���㷨�ȶ����Ѳ���
%uodate-12-31 ��Ϊ���󱻷�Ϊ����С�����֣�����д

[row_num, ~] = size(matrix);
if count_training == row_num
    matrix_training = matrix;
else
    matrix_training = [matrix(1:count_training, :); matrix(u, :)];
end
service_mean = mean(matrix_training, 'omitnan')';  %��ȡ����ƽ��ֵ,ע����ܴ���nanW
service_similarity = service_similarity_sparse(s, :);
% service_similarity(isnan(matrix(u, :))) = nan;


service_similarity(service_similarity <= 0) = nan;  %��С�ڵ���0��ȫ����Ϊnan
%�ҵ�top-k������������û�е��ù�����s�������ƶ�Ϊnan��������ھ�
[service_similarity, index] = sort(service_similarity, 'descend');  %��������index��ԭ�е��±�
%�������е�nan
filter = isnan(service_similarity);
service_similarity(filter) = [];
index(filter) = [];
%�ж�ʣ�µ�������k�Ĺ�ϵ�����С��top-k�������top-k
count = length(service_similarity);
con = 0;
if count == 0   %���û�н��ڣ�ֱ�ӷ���nan
    qos_value = nan;
    return
end
if count < top_k
    top_k = count;
end
sum_similarity = sum(service_similarity(1:top_k));  %����top_k�����ƶȵĺ�
temp = 0;   %�洢��ʽ+���ұߵĲ���
for n = 1:top_k
    entry = matrix(u, index(n));
    %ĳЩ���ڲ�û�е��ù�����s��ô��
    if(isnan(entry))
        entry = 0;
    end
    w = service_similarity(n) / sum_similarity;    %Ȩֵ�������������ƶ�
    con = con + service_similarity(n) * service_similarity(n) / sum_similarity;
    temp = temp + (entry - service_mean(index(n))) * w;
end
qos_value = service_mean(s) + temp;    %���ս��
if qos_value < 0
    qos_value = 0;
elseif qos_value > 20
    qos_value = 20;
end