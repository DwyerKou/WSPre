function qos_value = WSRec(qos_upcc, qos_ipcc, w, flag, pu, ps)
%%WSrec
% update2016-2-9
%   ��С��0�����20�޸�Ϊnan
wu = w;
wi = 1 - w;
if ~isnan(qos_upcc) && ~isnan(qos_ipcc)
    qos_value = wu * qos_upcc + wi * qos_ipcc;
elseif isnan(qos_upcc) && ~isnan(qos_ipcc)
    qos_value = qos_ipcc;
elseif ~isnan(qos_upcc) && isnan(qos_ipcc)
    qos_value = qos_upcc;
else
    if flag == 1 %���ѵ����
        qos_value = nan;
    end
    if flag == 2 %Ԥ����Լ�
        qos_value = wu * pu + wi * ps;
    end
end
if qos_value < 0
    qos_value = 0;
elseif qos_value > 20
    qos_value = 20;
end