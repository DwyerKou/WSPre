function result = MissingValuePrediction(matrix_sparse, nagetive_filter, top_k, w, user_similarity_sparse, service_similarity_sparse)
%%����������ȱʧ���ݽ������
%matrix_sparse ϡ�����
%nagetive_filter ����������ҪԤ���ֵ

[row_num, col_num] = size(matrix_sparse);
result = matrix_sparse;
h = waitbar(0, '1', 'Name', 'ȱʧֵ�����...');
step = 0;
count = numel(find(nagetive_filter == 1));
%��ʼԤ��ÿһ��Ϊnan��ֵ
for u = 1:row_num
    for s = 1:col_num
        if nagetive_filter(u, s) == 1
            UPCC = UPCC_nan(matrix_sparse, row_num, u, s, top_k, user_similarity_sparse);
            IPCC = IPCC_nan(matrix_sparse, row_num, u, s, top_k, service_similarity_sparse);
            flag_first = 1; %���һ��������ʾ�ǵ�һ�����ѵ����������ʹ��WSRec����
            result(u, s) = WSRec(UPCC, IPCC, w, flag_first);
            step = step + 1;
            waitbar(step / count, h, [int2str(step) '/' int2str(count)]);
        end
    end
end
close(h);