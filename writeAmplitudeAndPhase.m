function writeAmplitudeAndPhase(matrix, ampFilename, phaseFilename)
    % writeAmplitudeAndPhase 将矩阵的每一列的幅值和相位分别写入两个txt文件
    % 输入参数:
    %   matrix - 输入矩阵
    %   ampFilename - 保存幅值的txt文件名
    %   phaseFilename - 保存相位的txt文件名

    % 打开幅值文件以供写入
    fidAmp = fopen(ampFilename, 'w');
    if fidAmp == -1
        error('无法打开文件 %s', ampFilename);
    end

    % 打开相位文件以供写入
    fidPhase = fopen(phaseFilename, 'w');
    if fidPhase == -1
        fclose(fidAmp);
        error('无法打开文件 %s', phaseFilename);
    end

    % 获取矩阵的列数
    [~, numCols] = size(matrix);

    % 遍历每一列
    for col = 1:numCols
        % 获取当前列
        currentCol = matrix(:, col);
        
        % 计算幅值和相位
        amplitude = abs(currentCol);
        phase = angle(currentCol);
        
        % 将幅值写入文件
%         fprintf(fidAmp, 'Column %d:\n', col);
        fprintf(fidAmp, '%f ', amplitude);
        fprintf(fidAmp, '\n');
        
        % 将相位写入文件
%         fprintf(fidPhase, 'Column %d:\n', col);
        fprintf(fidPhase, '%f ', phase);
        fprintf(fidPhase, '\n');
    end

    % 关闭文件
    fclose(fidAmp);
    fclose(fidPhase);
end
