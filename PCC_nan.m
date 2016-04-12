function PCC_original_value = PCC_nan(m, n, matrix, matrix_mean)
%%ԭʼPCC��������ֵ����nan����
%���룺
%   m,n������������������±꣬��������
%   matrix�����ݾ���
%   matrix_mean����ǰ�������ÿһ�е�ƽ��ֵ
%����ֵ��
%   ����һ��1*1��һ��doubleֵ����Χ[-1.1]���������nan
%ע�⣺
%   ��ʡʱ�䣬û��Ҫ�������
%   �ú�������ֵ����Ϊnan
%   ���m����n��mean��nan��Ҳ����˵��m��nû��ʹ�ù��κ��е����ݣ���ô������ֱ��m��n�����ƶ�Ϊ0,Ҳ���ǲ����
%   m, n ��ͬ�᷵��1��û�з���nan����Ϊ�������������������������Ĺ��������������Ĺ�������һ��
%   ������û�е��ù���ͬ���У�����0
%   ���ս����nanֻ��һ�ֿ��ܣ����Ƿ�ĸΪ0����ʾm��n��ͬ���õ���Щ���ϣ�ֵ��ȫ��ͬ
%date:2015.12.16
%author:DwyerKou
%update_12.18
%   ���������ֱ߽�����Ĵ���
%   �Լ�д����������һ���ܳ����Ľ�������ֶ�����Ľ������֤ͨ�������ֱ߽����Ҳ�Ѿ���֤ͨ��
%update-12-25   ��Ľ������øĽ���PCC�����巽���г�ϣ�ģ�֣�ӱ�ģ��Լ�jaccard��.��һЩ���ƶ�����Ϊnan

%��ȡ���е�ƽ��ֵ
m_mean = matrix_mean(m);
n_mean = matrix_mean(n);

%�߽����1,m��nû��ʹ�ù��κ��е����ݣ���ô��������Ϊm��n�����ƶ�Ϊnan��Ҳ����û������
%�߽����2���Լ����Լ����ƶ�ֱ����nan

if isnan(m_mean) || isnan(n_mean) || m == n
    PCC_original_value = nan;
    return
end

%��ȡ��m��i���루n��i���Բ�Ϊnan����Щi��
m_filter = ~isnan(matrix(m, :));    %m�в�Ϊnan����
n_filter = ~isnan(matrix(n, :));    %n�в�Ϊnan����
col_filter = m_filter & n_filter;   %�����㣬m��n�нԲ�Ϊnan����
%�߽����3�������ù��У���û�е��ù���ͬ���У��涨���ƶ�Ϊnan
if  sum(col_filter) == 0
    PCC_original_value = nan;
    return;
end


%����
numerator = sum((matrix(m,col_filter) - m_mean) .* (matrix(n,col_filter) - n_mean));
%��ĸ
denominator = sqrt(sum((matrix(m,col_filter) - m_mean) .^ 2)) * sqrt(sum((matrix(n,col_filter) - n_mean) .^ 2));
%�Ľ�
mANDn_num = numel(find(col_filter == 1));
mPLUSn_num = numel(find(m_filter == 1)) + numel(find(n_filter == 1));
w = 2 * mANDn_num / mPLUSn_num;
PCC_original_value = numerator / denominator * w;

