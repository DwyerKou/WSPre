function PCC_original_value = PCC_nan(m, n, matrix, matrix_mean)
%%原始PCC函数，空值当做nan处理
%输入：
%   m,n是输入的两个变量的下标，都在行上
%   matrix是数据矩阵
%   matrix_mean是提前计算出的每一行的平均值
%返回值：
%   就是一个1*1的一个double值，范围[-1.1]，不会出现nan
%注意：
%   很省时间，没必要搞进度条
%   该函数将空值处理为nan
%   如果m或者n的mean是nan，也就是说明m或n没有使用过任何列的数据，那么本函数直接m与n的相似度为0,也就是不相关
%   m, n 相同会返回1（没有返回nan，是为了让这个函数单独做这个函数的工作，别与其他的工作混在一起）
%   若他们没有调用过相同的列，返回0
%   最终结果是nan只有一种可能，就是分母为0，表示m或n共同调用的那些列上，值完全相同
%date:2015.12.16
%author:DwyerKou
%update_12.18
%   考虑了四种边界情况的处理；
%   自己写函数测试了一遍跑出来的结果，和手动计算的结果，验证通过；四种边界情况也已经验证通过
%update-12-25   大改进，采用改进的PCC，具体方法有陈希的，郑子彬的，以及jaccard的.将一些相似度设置为nan

%获取两行的平均值
m_mean = matrix_mean(m);
n_mean = matrix_mean(n);

%边界情况1,m或n没有使用过任何列的数据，那么本函数认为m与n的相似度为nan，也就是没法评估
%边界情况2，自己与自己相似度直接是nan

if isnan(m_mean) || isnan(n_mean) || m == n
    PCC_original_value = nan;
    return
end

%获取（m，i）与（n，i）皆不为nan的那些i列
m_filter = ~isnan(matrix(m, :));    %m行不为nan的列
n_filter = ~isnan(matrix(n, :));    %n行不为nan的列
col_filter = m_filter & n_filter;   %与运算，m行n行皆不为nan的列
%边界情况3，都调用过列，但没有调用过相同的列，规定相似度为nan
if  sum(col_filter) == 0
    PCC_original_value = nan;
    return;
end


%分子
numerator = sum((matrix(m,col_filter) - m_mean) .* (matrix(n,col_filter) - n_mean));
%分母
denominator = sqrt(sum((matrix(m,col_filter) - m_mean) .^ 2)) * sqrt(sum((matrix(n,col_filter) - n_mean) .^ 2));
%改进
mANDn_num = numel(find(col_filter == 1));
mPLUSn_num = numel(find(m_filter == 1)) + numel(find(n_filter == 1));
w = 2 * mANDn_num / mPLUSn_num;
PCC_original_value = numerator / denominator * w;

