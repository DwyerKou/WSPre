function qos_value = UPCC_nan(matrix, count_training, u, s, top_k, user_similarity_sparse)
%%基于UPCC预测u调用s的QoS值 普通UPCC
%input：
%data得到的稀疏矩阵，u是用户下标，s服务下标,top_k是选取的近邻的个数,count_training训练集的个数
%output：qos_value预测到的值
%注意：
%   很省时间，没必要搞进度条
%   会忽略相似度<=0的邻居
%   将近邻调用s为null的置为0了，这里后续可以采用平滑处理
%author：Dwyer
%creatDate：2015.12.18
%update_12.18
%   添加过滤器提前过滤nan，同时依旧能在index中保存在matrix中的位置
%   测试通过，按照预期跑出结果，但是直接观察结果差好多啊
%update_12.23
%   如果没有近邻，则直接返回预测值nan
%   预测结果超过20，直接置为nan
%update_12.24 该算法稳定，已测试
%update-12-25 修改输出，小于0的统一设为0
%               只有调用过服务s的才称得上近邻
%update-12-26 没有邻居输出为nan
%       考虑到预测出来的大于20与小于0对预测UIPCC都有帮助，所以不在这里处理大于20小于0的情况，交给PredictQoS
%update-12-27 将没有调用服务s的全部设置为0,这样才是最原始的WSRec
%update-12-30 u的邻居只能在训练集中取
%2016-3-30 是时候认真考虑有些近邻没有调用过服务s的情况了

[row_num, ~] = size(matrix);
user_mean = mean(matrix, 2, 'omitnan')';  %获取用户平均值,注意可能存在nan

%计算u与每个训练集的距离，保存在一个向量中，介于[-1,1]，不会出现nan
% user_similarity = zeros(1, count_training);   %初始化用户相似度为0
% for m = 1:count_training %12.30改 邻居只有训练集
%     user_similarity(m) = PCC_nan(u, m, matrix, user_mean);  %调用PCC，计算相似度，可能返回nan详情见PCC定义
% end
user_similarity = user_similarity_sparse(u, 1:count_training);%假如为140个测试集，则这个为1*140大小

%处理未调用过服务s的用户的的办法1
% if count_training == row_num
%     user_similarity(isnan(matrix(:, s))) = nan;
% else
%     temp_matrix = matrix(1 : count_training, :);
%     user_similarity(isnan(temp_matrix(:, s))') = nan;    %将没有调用过服务s的用户相似度全部设为nan
% end

user_similarity(user_similarity <= 0) = nan;  %将小于等于0的全部设为nan
[user_similarity, index] = sort(user_similarity, 'descend');  %降序排序，index是原有的下标
%过滤所有的负相关邻居
filter = isnan(user_similarity);
user_similarity(filter) = [];
index(filter) = [];
%判断剩下的数量和k的关系，如果小于top-k，则更新top-k
count = length(user_similarity);
if count == 0   %如果没有近邻，直接返回nan
    qos_value = nan;
    return
end
if count < top_k
    top_k = count;
end

sum_similarity = sum(user_similarity(1:top_k));  %计算top_k个相似度的和
temp = 0;   %存储公式+号右边的部分
for n = 1:top_k
    entry = matrix(index(n), s);
    %数据平滑
    if(isnan(entry))
        entry = user_mean(index(n));
    end
    w = user_similarity(n) / sum_similarity;    %权值调整，基于相似度
    temp = temp + (entry - user_mean(index(n))) * w;
end
qos_value = user_mean(u) + temp;

if qos_value < 0
    qos_value = 0;
elseif qos_value > 20
    qos_value = 20;
end