function qos_value = UPCC_nan(matrix, count_training, u, s, top_k, user_similarity_sparse)
%%����UPCCԤ��u����s��QoSֵ ��ͨUPCC
%input��
%data�õ���ϡ�����u���û��±꣬s�����±�,top_k��ѡȡ�Ľ��ڵĸ���,count_trainingѵ�����ĸ���
%output��qos_valueԤ�⵽��ֵ
%ע�⣺
%   ��ʡʱ�䣬û��Ҫ�������
%   ��������ƶ�<=0���ھ�
%   �����ڵ���sΪnull����Ϊ0�ˣ�����������Բ���ƽ������
%author��Dwyer
%creatDate��2015.12.18
%update_12.18
%   ��ӹ�������ǰ����nan��ͬʱ��������index�б�����matrix�е�λ��
%   ����ͨ��������Ԥ���ܳ����������ֱ�ӹ۲�����öడ
%update_12.23
%   ���û�н��ڣ���ֱ�ӷ���Ԥ��ֵnan
%   Ԥ��������20��ֱ����Ϊnan
%update_12.24 ���㷨�ȶ����Ѳ���
%update-12-25 �޸������С��0��ͳһ��Ϊ0
%               ֻ�е��ù�����s�ĲųƵ��Ͻ���
%update-12-26 û���ھ����Ϊnan
%       ���ǵ�Ԥ������Ĵ���20��С��0��Ԥ��UIPCC���а��������Բ������ﴦ�����20С��0�����������PredictQoS
%update-12-27 ��û�е��÷���s��ȫ������Ϊ0,����������ԭʼ��WSRec
%update-12-30 u���ھ�ֻ����ѵ������ȡ
%2016-3-30 ��ʱ�����濼����Щ����û�е��ù�����s�������

[row_num, ~] = size(matrix);
user_mean = mean(matrix, 2, 'omitnan')';  %��ȡ�û�ƽ��ֵ,ע����ܴ���nan

%����u��ÿ��ѵ�����ľ��룬������һ�������У�����[-1,1]���������nan
% user_similarity = zeros(1, count_training);   %��ʼ���û����ƶ�Ϊ0
% for m = 1:count_training %12.30�� �ھ�ֻ��ѵ����
%     user_similarity(m) = PCC_nan(u, m, matrix, user_mean);  %����PCC���������ƶȣ����ܷ���nan�����PCC����
% end
user_similarity = user_similarity_sparse(u, 1:count_training);%����Ϊ140�����Լ��������Ϊ1*140��С

%����δ���ù�����s���û��ĵİ취1
% if count_training == row_num
%     user_similarity(isnan(matrix(:, s))) = nan;
% else
%     temp_matrix = matrix(1 : count_training, :);
%     user_similarity(isnan(temp_matrix(:, s))') = nan;    %��û�е��ù�����s���û����ƶ�ȫ����Ϊnan
% end

user_similarity(user_similarity <= 0) = nan;  %��С�ڵ���0��ȫ����Ϊnan
[user_similarity, index] = sort(user_similarity, 'descend');  %��������index��ԭ�е��±�
%�������еĸ�����ھ�
filter = isnan(user_similarity);
user_similarity(filter) = [];
index(filter) = [];
%�ж�ʣ�µ�������k�Ĺ�ϵ�����С��top-k�������top-k
count = length(user_similarity);
if count == 0   %���û�н��ڣ�ֱ�ӷ���nan
    qos_value = nan;
    return
end
if count < top_k
    top_k = count;
end

sum_similarity = sum(user_similarity(1:top_k));  %����top_k�����ƶȵĺ�
temp = 0;   %�洢��ʽ+���ұߵĲ���
for n = 1:top_k
    entry = matrix(index(n), s);
    %����ƽ��
    if(isnan(entry))
        entry = user_mean(index(n));
    end
    w = user_similarity(n) / sum_similarity;    %Ȩֵ�������������ƶ�
    temp = temp + (entry - user_mean(index(n))) * w;
end
qos_value = user_mean(u) + temp;

if qos_value < 0
    qos_value = 0;
elseif qos_value > 20
    qos_value = 20;
end