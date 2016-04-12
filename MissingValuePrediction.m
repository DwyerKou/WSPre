function result = MissingValuePrediction(matrix_sparse, nagetive_filter, top_k, w, user_similarity_sparse, service_similarity_sparse)
%%对整个矩阵缺失数据进行填充
%matrix_sparse 稀疏矩阵
%nagetive_filter 整个矩阵需要预测的值

[row_num, col_num] = size(matrix_sparse);
result = matrix_sparse;
h = waitbar(0, '1', 'Name', '缺失值填充中...');
step = 0;
count = numel(find(nagetive_filter == 1));
%开始预测每一个为nan的值
for u = 1:row_num
    for s = 1:col_num
        if nagetive_filter(u, s) == 1
            UPCC = UPCC_nan(matrix_sparse, row_num, u, s, top_k, user_similarity_sparse);
            IPCC = IPCC_nan(matrix_sparse, row_num, u, s, top_k, service_similarity_sparse);
            flag_first = 1; %最后一个参数表示是第一步填出训练过程中在使用WSRec函数
            result(u, s) = WSRec(UPCC, IPCC, w, flag_first);
            step = step + 1;
            waitbar(step / count, h, [int2str(step) '/' int2str(count)]);
        end
    end
end
close(h);