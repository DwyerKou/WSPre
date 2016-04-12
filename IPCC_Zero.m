function qos_value = IPCC_Zero(matrix, count_training, u, s, top_k, service_similarity_sparse)
%%基于matrix，预测用户u调用s的QoS值,重写UPCC
%考虑到UPCC与IPCC算法完全相同，不同的是相当于把矩阵进行了转置
%update_12.24 该算法稳定，已测试
%uodate-12-31 因为矩阵被分为了上小两部分，单独写

[row_num, ~] = size(matrix);
if count_training == row_num
    matrix_training = matrix;
else
    matrix_training = [matrix(1:count_training, :); matrix(u, :)];
end
service_mean = mean(matrix_training, 'omitnan')';  %获取服务平均值,注意可能存在nanW
service_similarity = service_similarity_sparse(s, :);
% service_similarity(isnan(matrix(u, :))) = nan;


service_similarity(service_similarity <= 0) = nan;  %将小于等于0的全部设为nan
%找到top-k，如果这个近邻没有调用过服务s或者相似度为nan忽略这个邻居
[service_similarity, index] = sort(service_similarity, 'descend');  %降序排序，index是原有的下标
%过滤所有的nan
filter = isnan(service_similarity);
service_similarity(filter) = [];
index(filter) = [];
%判断剩下的数量和k的关系，如果小于top-k，则更新top-k
count = length(service_similarity);
con = 0;
if count == 0   %如果没有近邻，直接返回nan
    qos_value = nan;
    return
end
if count < top_k
    top_k = count;
end
sum_similarity = sum(service_similarity(1:top_k));  %计算top_k个相似度的和
temp = 0;   %存储公式+号右边的部分
for n = 1:top_k
    entry = matrix(u, index(n));
    %某些近邻并没有调用过服务s怎么办
    if(isnan(entry))
        entry = 0;
    end
    w = service_similarity(n) / sum_similarity;    %权值调整，基于相似度
    con = con + service_similarity(n) * service_similarity(n) / sum_similarity;
    temp = temp + (entry - service_mean(index(n))) * w;
end
qos_value = service_mean(s) + temp;    %最终结果
if qos_value < 0
    qos_value = 0;
elseif qos_value > 20
    qos_value = 20;
end